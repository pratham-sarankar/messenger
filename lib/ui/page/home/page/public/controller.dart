// Copyright © 2022-2023 IT ENGINEERING MANAGEMENT INC,
//                       <https://github.com/team113>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License v3.0 as published by the
// Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License v3.0 for
// more details.
//
// You should have received a copy of the GNU Affero General Public License v3.0
// along with this program. If not, see
// <https://www.gnu.org/licenses/agpl-3.0.html>.

import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/domain/model/attachment.dart';
import 'package:messenger/domain/model/chat.dart';
import 'package:messenger/domain/model/chat_call.dart';
import 'package:messenger/domain/model/chat_info.dart';
import 'package:messenger/domain/model/chat_item.dart';
import 'package:messenger/domain/model/my_user.dart';
import 'package:messenger/domain/model/native_file.dart';
import 'package:messenger/domain/model/precise_date_time/precise_date_time.dart';
import 'package:messenger/domain/model/sending_status.dart';
import 'package:messenger/domain/model/user.dart';
import 'package:messenger/domain/repository/chat.dart';
import 'package:messenger/domain/repository/user.dart';
import 'package:messenger/domain/service/auth.dart';
import 'package:messenger/domain/service/chat.dart';
import 'package:messenger/domain/service/my_user.dart';
import 'package:messenger/domain/service/user.dart';
import 'package:messenger/l10n/l10n.dart';
import 'package:messenger/provider/gql/exceptions.dart';
import 'package:messenger/ui/page/home/page/chat/controller.dart';
import 'package:messenger/ui/page/home/page/chat/message_field/controller.dart';
import 'package:messenger/ui/widget/text_field.dart';
import 'package:messenger/util/message_popup.dart';
import 'package:messenger/util/obs/obs.dart';
import 'package:messenger/util/platform_utils.dart';

class PublicController extends GetxController {
  PublicController(
    this.id,
    this._authService,
    this._myUserService,
    this._chatService,
    this._userService,
  );

  final ChatId id;

  RxChat? chat;

  late final TextFieldState send;

  final Rx<RxStatus> status = Rx(RxStatus.loading());

  /// [RxSplayTreeMap] of the [ListElement]s to display.
  final RxObsSplayTreeMap<ListElementId, ListElement> elements =
      RxObsSplayTreeMap();

  RxList<Attachment> attachments = RxList<Attachment>();
  final Rx<Attachment?> hoveredAttachment = Rx(null);

  final AuthService _authService;
  final MyUserService _myUserService;
  final ChatService _chatService;

  /// Subscription for the [RxChat.messages] updating the [elements].
  late final StreamSubscription _messagesSubscription;

  /// [User]s service fetching the [User]s in [getUser] method.
  final UserService _userService;

  UserId? get me => _authService.userId;
  Rx<MyUser?> get myUser => _myUserService.myUser;

  @override
  void onInit() {
    _fetchChat();

    send = TextFieldState(
      onChanged: (s) => s.error.value = null,
      onSubmitted: (s) async {
        if (s.text.isNotEmpty || attachments.isNotEmpty) {
          _chatService
              .sendChatMessage(
                chat!.chat.value.id,
                text: s.text.isEmpty ? null : ChatMessageText(s.text),
                attachments: attachments,
              )
              .onError<PostChatMessageException>(
                  (e, _) => MessagePopup.error(e))
              .onError<UploadAttachmentException>(
                  (e, _) => MessagePopup.error(e))
              .onError<ConnectionException>((e, _) {});

          attachments.clear();
          s.clear();
          s.unsubmit();

          if (!PlatformUtils.isMobile) {
            Future.delayed(Duration.zero, () => s.focus.requestFocus());
          }
        }
      },
      focus: FocusNode(
        onKey: (FocusNode node, RawKeyEvent e) {
          if (e.logicalKey == LogicalKeyboardKey.enter &&
              e is RawKeyDownEvent) {
            bool handled = e.isShiftPressed;

            if (!PlatformUtils.isWeb) {
              if (PlatformUtils.isMacOS || PlatformUtils.isWindows) {
                handled = e.isAltPressed || e.isControlPressed;
              }
            }

            if (!handled) {
              if (e.isAltPressed ||
                  e.isControlPressed ||
                  e.isMetaPressed ||
                  e.isShiftPressed) {
                int cursor;

                if (send.controller.selection.isCollapsed) {
                  cursor = send.controller.selection.base.offset;
                  send.text =
                      '${send.text.substring(0, cursor)}\n${send.text.substring(cursor, send.text.length)}';
                } else {
                  cursor = send.controller.selection.start;
                  send.text =
                      '${send.text.substring(0, send.controller.selection.start)}\n${send.text.substring(send.controller.selection.end, send.text.length)}';
                }

                send.controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: cursor + 1),
                );
              } else {
                send.submit();
                return KeyEventResult.handled;
              }
            }
          }

          return KeyEventResult.ignored;
        },
      ),
    );

    super.onInit();
  }

  @override
  void onClose() {
    _messagesSubscription.cancel();

    // AudioCache.instance.clear('audio/message_sent.mp3');
  }

  /// Deletes the specified [ChatItem] posted by the authenticated [MyUser].
  Future<void> deleteMessage(ChatItem item) async {
    try {
      await _chatService.deleteChatItem(item);
    } on DeleteChatMessageException catch (e) {
      MessagePopup.error(e);
    } on DeleteChatForwardException catch (e) {
      MessagePopup.error(e);
    } catch (e) {
      MessagePopup.error(e);
      rethrow;
    }
  }

  /// Opens a media choose popup and adds the selected files to the
  /// [attachments].
  Future<void> pickMedia() =>
      _pickAttachment(PlatformUtils.isIOS ? FileType.media : FileType.image);

  /// Opens the camera app and adds the captured image to the [attachments].
  Future<void> pickImageFromCamera() async {
    // TODO: Remove the limitations when bigger files are supported on backend.
    final XFile? photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (photo != null) {
      _addXFileAttachment(photo);
    }
  }

  /// Opens the camera app and adds the captured video to the [attachments].
  Future<void> pickVideoFromCamera() async {
    // TODO: Remove the limitations when bigger files are supported on backend.
    final XFile? video = await ImagePicker().pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 15),
    );

    if (video != null) {
      _addXFileAttachment(video);
    }
  }

  /// Returns an [User] from [UserService] by the provided [id].
  FutureOr<RxUser?> getUser(UserId id) => _userService.get(id);

  /// Returns a [List] of [Attachment]s representing a collection of all the
  /// media files of this [chat].
  List<Attachment> calculateGallery() {
    final List<Attachment> attachments = [];

    for (var m in chat?.messages ?? <Rx<ChatItem>>[]) {
      if (m.value is ChatMessage) {
        final ChatMessage msg = m.value as ChatMessage;
        attachments.addAll(msg.attachments.where(
          (e) => e is ImageAttachment || (e is FileAttachment && e.isVideo),
        ));
      } else if (m.value is ChatForward) {
        // final ChatForward msg = m.value as ChatForward;
        // final ChatItem item = msg.item;

        // if (item is ChatMessage) {
        //   attachments.addAll(item.attachments.where(
        //     (e) => e is ImageAttachment || (e is FileAttachment && e.isVideo),
        //   ));
        // }
      }
    }

    return attachments;
  }

  /// [Timer] for discarding any vertical movement in a [SingleChildScrollView]
  /// of [ChatItem]s when non-`null`.
  ///
  /// Indicates currently ongoing horizontal scroll of a view.
  final Rx<Timer?> horizontalScrollTimer = Rx(null);

  /// Opens a file choose popup and adds the selected files to the
  /// [attachments].
  Future<void> pickFile() => _pickAttachment(FileType.any);

  /// Constructs a [NativeFile] from the specified [PlatformFile] and adds it
  /// to the [attachments].
  @visibleForTesting
  Future<void> addPlatformAttachment(PlatformFile platformFile) async {
    NativeFile nativeFile = NativeFile.fromPlatformFile(platformFile);
    await _addAttachment(nativeFile);
  }

  /// Constructs a [NativeFile] from the specified [XFile] and adds it to the
  /// [attachments].
  Future<void> _addXFileAttachment(XFile xFile) async {
    NativeFile nativeFile = NativeFile.fromXFile(xFile, await xFile.length());
    await _addAttachment(nativeFile);
  }

  /// Constructs a [LocalAttachment] from the specified [file] and adds it to
  /// the [attachments] list.
  ///
  /// May be used to test a [file] upload since [FilePicker] can't be mocked.
  Future<void> _addAttachment(NativeFile file) async {
    if (file.size < MessageFieldController.maxAttachmentSize) {
      try {
        var attachment = LocalAttachment(file, status: SendingStatus.sending);
        attachments.add(attachment);

        Attachment uploaded = await _chatService.uploadAttachment(attachment);

        int index = attachments.indexOf(attachment);
        if (index != -1) {
          attachments[index] = uploaded;
        }
      } on UploadAttachmentException catch (e) {
        MessagePopup.error(e);
      } on ConnectionException {
        // No-op.
      }
    } else {
      MessagePopup.error('err_size_too_big'.l10n);
    }
  }

  /// Opens a file choose popup of the specified [type] and adds the selected
  /// files to the [attachments].
  Future<void> _pickAttachment(FileType type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: true,
      withReadStream: true,
    );

    if (result != null && result.files.isNotEmpty) {
      for (PlatformFile e in result.files) {
        addPlatformAttachment(e);
      }
    }
  }

  Future<void> _fetchChat() async {
    status.value = RxStatus.loading();
    chat = await _chatService.get(id);
    if (chat == null) {
      status.value = RxStatus.empty();
    } else {
      // Adds the provided [ChatItem] to the [elements].
      void add(Rx<ChatItem> e) {
        ChatItem item = e.value;

        // Put a [DateTimeElement] with [ChatItem.at] day, if not already.
        PreciseDateTime day = item.at.toDay();
        DateTimeElement dateElement = DateTimeElement(day);
        elements.putIfAbsent(dateElement.id, () => dateElement);

        if (item is ChatMessage) {
          ChatMessageElement element = ChatMessageElement(e);
          elements[element.id] = element;
        } else if (item is ChatCall) {
          ChatCallElement element = ChatCallElement(e);
          elements[element.id] = element;
        } else if (item is ChatInfo) {
          ChatInfoElement element = ChatInfoElement(e);
          elements[element.id] = element;
        } else if (item is ChatForward) {
          ChatForwardElement element =
              ChatForwardElement(forwards: [e], e.value.at);
          elements[element.id] = element;
        }
      }

      for (Rx<ChatItem> e in chat!.messages) {
        add(e);
      }

      _messagesSubscription = chat!.messages.changes.listen((e) {
        switch (e.op) {
          case OperationKind.added:
            add(e.element);
            break;

          case OperationKind.removed:
            ChatItem item = e.element.value;

            ListElementId key = ListElementId(item.at, item.id);
            ListElement? element = elements[key];

            ListElementId? before = elements.lastKeyBefore(key);
            ListElement? beforeElement = elements[before];

            ListElementId? after = elements.firstKeyAfter(key);
            ListElement? afterElement = elements[after];

            // Remove the [DateTimeElement] before, if this [ChatItem] is the
            // last in this [DateTime] period.
            if (beforeElement is DateTimeElement &&
                (afterElement == null || afterElement is DateTimeElement) &&
                (element is! ChatForwardElement ||
                    (element.forwards.length == 1 &&
                        element.note.value == null))) {
              elements.remove(before);
            }

            // When removing [ChatMessage] or [ChatForward], the [before] and
            // [after] elements must be considered as well, since they may be
            // grouped in the same [ChatForwardElement].
            if (item is ChatMessage) {
              if (element is ChatMessageElement &&
                  item.id == element.item.value.id) {
                elements.remove(key);
              } else if (beforeElement is ChatForwardElement &&
                  beforeElement.note.value?.value.id == item.id) {
                beforeElement.note.value = null;
              } else if (afterElement is ChatForwardElement &&
                  afterElement.note.value?.value.id == item.id) {
                afterElement.note.value = null;
              } else if (element is ChatForwardElement &&
                  element.note.value?.value.id == item.id) {
                element.note.value = null;
              }
            } else if (item is ChatCall && element is ChatCallElement) {
              if (item.id == element.item.value.id) {
                elements.remove(key);
              }
            } else if (item is ChatInfo && element is ChatInfoElement) {
              if (item.id == element.item.value.id) {
                elements.remove(key);
              }
            } else if (item is ChatForward) {
              ChatForwardElement? forward;

              if (beforeElement is ChatForwardElement &&
                  beforeElement.forwards.any((e) => e.value.id == item.id)) {
                forward = beforeElement;
              } else if (afterElement is ChatForwardElement &&
                  afterElement.forwards.any((e) => e.value.id == item.id)) {
                forward = afterElement;
              } else if (element is ChatForwardElement &&
                  element.forwards.any((e) => e.value.id == item.id)) {
                forward = element;
              }

              if (forward != null) {
                forward.forwards.removeWhere((e) => e.value.id == item.id);

                if (forward.forwards.isEmpty) {
                  elements.remove(forward.id);

                  if (forward.note.value != null) {
                    ChatMessageElement message =
                        ChatMessageElement(forward.note.value!);
                    elements[message.id] = message;
                  }
                }
              }
            }
            break;

          case OperationKind.updated:
            // No-op.
            break;
        }
      });

      status.value = RxStatus.loadingMore();
      // await chat!.fetchMessages();
      status.value = RxStatus.success();
    }
  }
}
