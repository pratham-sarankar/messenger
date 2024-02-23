// Copyright © 2022-2024 IT ENGINEERING MANAGEMENT INC,
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

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:messenger/config.dart';
import 'package:messenger/ui/page/home/page/chat/get_paid/controller.dart';
import 'package:messenger/ui/page/home/page/chat/get_paid/view.dart';
import 'package:messenger/ui/page/home/page/chat/widget/chat_subtitle.dart';
import 'package:messenger/ui/page/home/page/user/widget/contact_info.dart';
import 'package:messenger/ui/page/home/page/user/widget/copy_or_share.dart';
import 'package:messenger/ui/page/home/widget/paddings.dart';
import 'package:messenger/ui/widget/animated_size_and_fade.dart';
import 'package:messenger/ui/widget/animated_switcher.dart';
import 'package:messenger/ui/widget/context_menu/menu.dart';
import 'package:messenger/ui/widget/context_menu/region.dart';
import 'package:messenger/ui/widget/widget_button.dart';
import 'package:share_plus/share_plus.dart';

import '/domain/model/chat.dart';
import '/domain/repository/user.dart';
import '/l10n/l10n.dart';
import '/routes.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/widget/back_button.dart';
import '/ui/page/home/widget/action.dart';
import '/ui/page/home/widget/app_bar.dart';
import '/ui/page/home/widget/avatar.dart';
import '/ui/page/home/widget/big_avatar.dart';
import '/ui/page/home/widget/block.dart';
import '/ui/page/home/widget/direct_link.dart';
import '/ui/widget/animated_button.dart';
import '/ui/widget/member_tile.dart';
import '/ui/widget/progress_indicator.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import '/util/message_popup.dart';
import '/util/platform_utils.dart';
import 'add_member/view.dart';
import 'controller.dart';
import 'widget/chat_bio.dart';

/// View of the [Routes.chatInfo] page.
class ChatInfoView extends StatelessWidget {
  const ChatInfoView(this.id, {super.key});

  /// ID of the [Chat] of this info page.
  final ChatId id;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return GetBuilder<ChatInfoController>(
      key: const Key('ChatInfoView'),
      init: ChatInfoController(
        id,
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
      ),
      tag: id.val,
      global: !Get.isRegistered<ChatInfoController>(tag: id.val),
      builder: (c) {
        return Obx(() {
          if (c.status.value.isLoading) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CustomProgressIndicator()),
            );
          } else if (!c.status.value.isSuccess) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text('label_no_chat_found'.l10n)),
            );
          }

          final Widget editButton = Obx(() {
            final bool favorite = c.chat?.chat.value.favoritePosition != null;
            final bool hasCall = c.chat?.chat.value.ongoingCall != null;

            return ContextMenuRegion(
              key: c.moreKey,
              selector: c.moreKey,
              alignment: Alignment.topRight,
              enablePrimaryTap: true,
              margin: const EdgeInsets.only(bottom: 4, left: 20),
              actions: [
                ContextMenuButton(
                  label: 'Открыть чат'.l10n,
                  onPressed: () => router.chat(id),
                  trailing: const SvgIcon(SvgIcons.chat18),
                  inverted: const SvgIcon(SvgIcons.chat18White),
                ),
                ContextMenuButton(
                  label: 'btn_audio_call'.l10n,
                  onPressed: hasCall ? null : () => c.call(false),
                  trailing: hasCall
                      ? const SvgIcon(SvgIcons.makeAudioCallDisabled)
                      : const SvgIcon(SvgIcons.makeAudioCall),
                  inverted: const SvgIcon(SvgIcons.makeAudioCallWhite),
                ),
                ContextMenuButton(
                  label: 'btn_video_call'.l10n,
                  onPressed: hasCall ? null : () => c.call(true),
                  trailing: Transform.translate(
                    offset: const Offset(2, 0),
                    child: hasCall
                        ? const SvgIcon(SvgIcons.makeVideoCallDisabled)
                        : const SvgIcon(SvgIcons.makeVideoCall),
                  ),
                  inverted: Transform.translate(
                    offset: const Offset(2, 0),
                    child: const SvgIcon(SvgIcons.makeVideoCallWhite),
                  ),
                ),
                ContextMenuButton(
                  label: favorite
                      ? 'btn_delete_from_favorites'.l10n
                      : 'btn_add_to_favorites'.l10n,
                  onPressed: favorite ? c.unfavoriteChat : c.favoriteChat,
                  trailing: SvgIcon(
                    favorite
                        ? SvgIcons.favoriteSmall
                        : SvgIcons.unfavoriteSmall,
                  ),
                  inverted: SvgIcon(
                    favorite
                        ? SvgIcons.favoriteSmallWhite
                        : SvgIcons.unfavoriteSmallWhite,
                  ),
                ),
                if (!c.isMonolog)
                  ContextMenuButton(
                    onPressed: c.report,
                    label: 'btn_report'.l10n,
                    trailing: const SvgIcon(SvgIcons.report),
                    inverted: const SvgIcon(SvgIcons.reportWhite),
                  ),
                ContextMenuButton(
                  onPressed: () => _clearChat(c, context),
                  label: 'btn_clear_history'.l10n,
                  trailing: const SvgIcon(SvgIcons.cleanHistory),
                  inverted: const SvgIcon(SvgIcons.cleanHistoryWhite),
                ),
                ContextMenuButton(
                  key: const Key('HideChatButton'),
                  onPressed: () => _hideChat(c, context),
                  label: 'btn_delete_chat'.l10n,
                  trailing: const SvgIcon(SvgIcons.delete19),
                  inverted: const SvgIcon(SvgIcons.delete19White),
                ),
                if (!c.isMonolog)
                  ContextMenuButton(
                    onPressed: () => _leaveGroup(c, context),
                    label: 'btn_leave_group'.l10n,
                    trailing: const SvgIcon(SvgIcons.leaveGroup),
                    inverted: const SvgIcon(SvgIcons.leaveGroupWhite),
                  ),
              ],
              child: Container(
                padding: const EdgeInsets.only(left: 31, right: 25),
                height: double.infinity,
                child: const SvgIcon(SvgIcons.more),
              ),
            );
          });

          final Widget title;

          if (!c.displayName.value) {
            title = Row(
              key: const Key('Profile'),
              children: [
                const StyledBackButton(),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                    child: Center(child: Text('label_profile'.l10n)),
                  ),
                ),
              ],
            );
          } else {
            title = Row(
              children: [
                const StyledBackButton(),
                Material(
                  elevation: 6,
                  type: MaterialType.circle,
                  shadowColor: style.colors.onBackgroundOpacity27,
                  color: style.colors.onPrimary,
                  child: AvatarWidget.fromRxChat(
                    c.chat,
                    radius: AvatarRadius.medium,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: DefaultTextStyle.merge(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          return Row(
                            children: [
                              Flexible(
                                child: Text(
                                  c.chat!.title.value,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Obx(() {
                                if (c.chat?.chat.value.muted == null) {
                                  return const SizedBox();
                                }

                                return const Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: SvgIcon(SvgIcons.muted),
                                );
                              }),
                            ],
                          );
                        }),
                        ChatSubtitle(c.chat!, c.me),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            );
          }

          return Scaffold(
            appBar: CustomAppBar(
              title: Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: title,
                    ),
                  ),
                  editButton,
                ],
              ),
            ),
            body: Obx(() {
              final Widget child;

              if (c.editing.value) {
                child = ListView(
                  key: const Key('Hello'),
                  children: [
                    const SizedBox(height: 8),
                    Block(
                      children: [
                        Padding(
                          padding: Insets.basic.copyWith(top: 0, bottom: 0),
                          child: BigAvatarWidget.chat(
                            c.chat,
                            key: Key('ChatAvatar_${c.chat!.id}'),
                            loading: c.avatar.value.isLoading,
                            onUpload: c.pickAvatar,
                            onDelete: c.chat?.avatar.value != null
                                ? c.deleteAvatar
                                : null,
                            error: c.avatar.value.errorMessage,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _padding(
                          ReactiveTextField(
                            key: const Key('RenameChatField'),
                            state: c.name,
                            label: c.chat?.chat.value.name == null
                                ? c.chat?.title.value
                                : 'label_name'.l10n,
                            hint: 'label_chat_name_hint'.l10n,
                          ),
                        ),
                      ],
                    ),
                    Block(
                      children: [
                        _padding(
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ReactiveTextField(
                              state: c.textStatus,
                              label: 'label_status'.l10n,
                              maxLines: null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Block(
                      title: 'label_direct_chat_link'.l10n,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            6,
                            0,
                            8,
                            24,
                          ),
                          child: Text(
                            'Пользователи, пришедшие по прямой ссылке, автоматически становятся полноправными участниками группы.',
                            style: style.fonts.small.regular.secondary,
                          ),
                        ),
                        DirectLinkField(
                          c.chat?.chat.value.directLink,
                          generated: id.val,
                          onSubmit: (s) => s == null
                              ? c.deleteChatDirectLink()
                              : c.createChatDirectLink(s),
                          background: c.background.value,
                          editing: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              } else {
                child = Scrollbar(
                  controller: c.scrollController,
                  child: SelectionArea(
                    child: ListView(
                      controller: c.scrollController,
                      key: const Key('ChatInfoScrollable'),
                      children: [
                        const SizedBox(height: 8),
                        Block(
                          overlay: [
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Center(
                                child: SelectionContainer.disabled(
                                  child: AnimatedButton(
                                    onPressed: c.profileEditing.toggle,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(6, 6, 0, 6),
                                      child: c.profileEditing.value
                                          ? const Padding(
                                              padding: EdgeInsets.all(2),
                                              child: SvgIcon(
                                                SvgIcons.closeSmallPrimary,
                                              ),
                                            )
                                          : const SvgIcon(SvgIcons.editSmall),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          children: [
                            SelectionContainer.disabled(
                              child: BigAvatarWidget.chat(
                                c.chat,
                                key: Key('ChatAvatar_${c.chat!.id}'),
                                loading: c.avatar.value.isLoading,
                                error: c.avatar.value.errorMessage,
                              ),
                            ),
                            Obx(() {
                              final List<Widget> children;

                              if (c.profileEditing.value) {
                                children = [
                                  const SizedBox(height: 4),
                                  SelectionContainer.disabled(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        WidgetButton(
                                          key: const Key('UploadAvatar'),
                                          onPressed: c.pickAvatar,
                                          child: Text(
                                            'btn_upload'.l10n,
                                            style: style
                                                .fonts.small.regular.primary,
                                          ),
                                        ),
                                        Text(
                                          'space_or_space'.l10n,
                                          style: style
                                              .fonts.small.regular.onBackground,
                                        ),
                                        WidgetButton(
                                          key: const Key('DeleteAvatar'),
                                          onPressed: c.deleteAvatar,
                                          child: Text(
                                            'btn_delete'.l10n.toLowerCase(),
                                            style: style
                                                .fonts.small.regular.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  SelectionContainer.disabled(
                                    child: ReactiveTextField(
                                      state: c.name,
                                      label: 'label_name'.l10n,
                                      hint: c.chat?.title.value,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ];
                              } else {
                                children = [
                                  const SizedBox(height: 18),
                                  Container(width: double.infinity),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: Text(
                                      c.chat?.title.value ?? c.name.text,
                                      style: style
                                          .fonts.large.regular.onBackground,
                                    ),
                                  ),
                                ];
                              }

                              return AnimatedSizeAndFade(
                                fadeDuration: 250.milliseconds,
                                sizeDuration: 250.milliseconds,
                                child: Column(
                                  key: Key(c.profileEditing.value.toString()),
                                  children: children,
                                ),
                              );
                            }),
                          ],
                        ),
                        _quick(c, context),
                        _status(c, context),
                        if (!c.isMonolog) ...[
                          SelectionContainer.disabled(
                            child: Block(
                              padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                              overlay: [
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: AnimatedButton(
                                    decorator: (child) => Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        2,
                                        4,
                                        2,
                                        2,
                                      ),
                                      child: child,
                                    ),
                                    onPressed: () => AddChatMemberView.show(
                                      context,
                                      chatId: id,
                                    ),
                                    child: const SvgIcon(
                                      SvgIcons.addMemberSmall,
                                    ),
                                  ),
                                ),
                              ],
                              title: 'label_participants'.l10nfmt(
                                {'count': c.chat!.members.length},
                              ),
                              children: [
                                // Padding(
                                //   padding: const EdgeInsets.fromLTRB(
                                //     8 + 0,
                                //     4,
                                //     0 + 0,
                                //     8 + 5,
                                //   ),
                                //   child: Row(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       Expanded(
                                //         child: Padding(
                                //           padding: const EdgeInsets.fromLTRB(
                                //             0,
                                //             8,
                                //             0,
                                //             0,
                                //           ),
                                //           child: Text(
                                //             'label_participants'.l10nfmt(
                                //               {'count': c.chat!.members.length},
                                //             ),
                                //             style: style
                                //                 .fonts.big.regular.onBackground,
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                _members(c, context),
                              ],
                            ),
                          ),
                          SelectionContainer.disabled(
                            child: Block(
                              title: 'label_direct_chat_link'.l10n,
                              padding:
                                  Block.defaultPadding.copyWith(bottom: 10),
                              overlay: [
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Center(
                                    child: SelectionContainer.disabled(
                                      child: AnimatedButton(
                                        onPressed: c.linkEditing.toggle,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            6,
                                            6,
                                            0,
                                            6,
                                          ),
                                          child: c.linkEditing.value
                                              ? const Padding(
                                                  padding: EdgeInsets.all(2),
                                                  child: SvgIcon(
                                                    SvgIcons.closeSmallPrimary,
                                                  ),
                                                )
                                              : const SvgIcon(
                                                  SvgIcons.editSmall,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              children: [_link(context, c)],
                            ),
                          ),
                        ],
                        SelectionContainer.disabled(
                          child: Block(children: [_actions(c, context)]),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.ease,
                switchOutCurve: Curves.ease,
                child: child,
              );
            }),
          );
        });
      },
    );
  }

  /// Basic [Padding] wrapper.
  Widget _padding(Widget child) =>
      Padding(padding: const EdgeInsets.all(8), child: child);

  /// Returns a [Chat.name] editable field.
  Widget _name(ChatInfoController c, BuildContext context) {
    final style = Theme.of(context).style;

    return Obx(() {
      final Widget child;

      if (c.editing.value) {
        child = _padding(
          ReactiveTextField(
            key: const Key('RenameChatField'),
            state: c.name,
            label: c.chat?.chat.value.name == null
                ? c.chat?.title.value
                : 'label_name'.l10n,
            hint: 'label_chat_name_hint'.l10n,
          ),
        );
      } else {
        child = Padding(
          key: const Key('Key'),
          padding: const EdgeInsets.only(top: 6),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Text(
                c.chat?.title.value ?? '...',
                style: style.fonts.large.regular.onBackground,
              ),
            ),
          ),
        );
      }

      return AnimatedSizeAndFade(
        sizeDuration: const Duration(milliseconds: 250),
        fadeDuration: const Duration(milliseconds: 250),
        child: child,
      );
    });
  }

  Widget _status(ChatInfoController c, BuildContext context) {
    final style = Theme.of(context).style;

    // return Obx(() {
    final Widget child;

    // if (c.bioEditing.value) {
    //   child = Padding(
    //     key: const Key('1'),
    //     padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
    //     child: SizedBox(
    //       width: double.infinity,
    //       child: Center(
    //         child: ReactiveTextField(
    //           state: c.textStatus,
    //           label: 'О группе',
    //           clearable: true,
    //         ),
    //       ),
    //     ),
    //   );
    // } else if (c.textStatus.text.isEmpty) {
    //   child = const Text(
    //     key: Key('2'),
    //     'Информация отсутствует',
    //   );
    // } else {
    //   child = SizedBox(
    //     key: const Key('3'),
    //     width: double.infinity,
    //     child: Center(
    //       child: Text(
    //         c.textStatus.text,
    //         style: style.fonts.normal.regular.secondary,
    //       ),
    //     ),
    //   );
    // }

    return Block(
      overlay: [
        Positioned(
          right: 0,
          top: 0,
          child: Center(
            child: SelectionContainer.disabled(
              child: AnimatedButton(
                onPressed: () {
                  c.bioEditing.toggle();
                  c.textStatus.unsubmit();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 0, 6),
                  child: c.bioEditing.value
                      ? const Padding(
                          padding: EdgeInsets.all(2),
                          child: SvgIcon(SvgIcons.closeSmallPrimary),
                        )
                      : const SvgIcon(SvgIcons.editSmall),
                ),
              ),
            ),
          ),
        ),
      ],
      title: 'О группе',
      children: [
        Obx(() {
          return ChatBioField(
            c.bio.value,
            editing: c.bioEditing.value,
            onEditing: (b) => c.bioEditing.value = b,
            onSubmit: (s) async {
              c.bio.value = s?.isNotEmpty == true ? s : null;
              c.bioEditing.value = false;
            },
          );
        }),
        // AnimatedSizeAndFade(
        //   fadeDuration: 250.milliseconds,
        //   sizeDuration: 250.milliseconds,
        //   child: child,
        // ),
      ],
    );
    // });
  }

  /// Returns a list of [Chat.members].
  Widget _members(ChatInfoController c, BuildContext context) {
    return Obx(() {
      final RxUser? me = c.chat!.members[c.me];
      final List<RxUser> members = [];

      for (var u in c.chat!.members.entries) {
        if (u.key != c.me) {
          members.add(u.value);
        }
      }

      members.sort((a, b) {
        final first = a.user.value.name?.val ?? a.user.value.num.val;
        final second = b.user.value.name?.val ?? b.user.value.num.val;
        return first.compareTo(second);
      });

      if (me != null) {
        members.insert(0, me);
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...members.map((e) {
            final bool inCall = c.chat?.chat.value.ongoingCall?.members
                    .any((u) => u.user.id == e.id) ==
                true;

            return MemberTile(
              user: e,
              me: e.id == c.me,
              inCall: c.chat?.chat.value.ongoingCall == null
                  ? null
                  : e.id == c.me
                      ? c.chat?.inCall.value == true
                      : inCall,
              onTap: () => router.chat(e.user.value.dialog, push: true),
              onCall: inCall
                  ? () => c.removeChatCallMember(e.id)
                  : e.id == c.me
                      ? c.joinCall
                      : () => c.redialChatCallMember(e.id),
              onKick: () => c.removeChatMember(e.id),
            );
          }),
        ],
      );
    });
  }

  /// Returns the action buttons to do with this [Chat].
  Widget _actions(ChatInfoController c, BuildContext context) {
    final bool favorite = c.chat?.chat.value.favoritePosition != null;
    final bool hasCall = c.chat?.chat.value.ongoingCall != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ActionButton(
          onPressed: favorite ? c.unfavoriteChat : c.favoriteChat,
          text: favorite
              ? 'btn_delete_from_favorites'.l10n
              : 'btn_add_to_favorites'.l10n,
          trailing: SvgIcon(
            favorite ? SvgIcons.favorite16 : SvgIcons.unfavorite16,
          ),
        ),
        if (!c.isMonolog)
          ActionButton(
            onPressed: c.report,
            text: 'btn_report'.l10n,
            trailing: Transform.translate(
              offset: const Offset(0, -1),
              child: const SvgIcon(SvgIcons.report16),
            ),
          ),
        ActionButton(
          key: const Key('ClearHistoryButton'),
          onPressed: () => _clearChat(c, context),
          text: 'btn_clear_history'.l10n,
          trailing: const SvgIcon(SvgIcons.cleanHistory16),
        ),
        ActionButton(
          key: const Key('HideChatButton'),
          onPressed: () => _hideChat(c, context),
          text: 'btn_delete_chat'.l10n,
          trailing: const SvgIcon(SvgIcons.delete),
        ),
        if (!c.isMonolog)
          ActionButton(
            onPressed: () => _leaveGroup(c, context),
            text: 'btn_leave_group'.l10n,
            trailing: const SvgIcon(SvgIcons.leaveGroup16),
          ),
      ],
    );
  }

  Widget _link(BuildContext context, ChatInfoController c) {
    final style = Theme.of(context).style;

    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              6,
              0,
              8,
              24,
            ),
            child: Text(
              'Пользователи, пришедшие по прямой ссылке, автоматически становятся полноправными участниками группы.',
              style: style.fonts.small.regular.secondary,
            ),
          ),
          DirectLinkField(
            c.chat?.chat.value.directLink,
            // generated: id.val, TODO: ALWAYS CREATE LINK WITH ID!!!
            onSubmit: (s) async {
              if (s == null) {
                await c.deleteChatDirectLink();
              } else {
                await c.createChatDirectLink(s);
              }
              c.linkEditing.value = false;
            },
            background: c.background.value,
            canDelete: false,
            editing: c.linkEditing.value,
            onEditing: (b) => c.linkEditing.value = b,
          ),
        ],
      );
    });
  }

  /// Returns information about the [Chat] and related to it action buttons in
  /// the [CustomAppBar].
  Widget _bar(ChatInfoController c, BuildContext context) {
    final style = Theme.of(context).style;

    return Center(
      child: Row(
        children: [
          const SizedBox(width: 8),
          const StyledBackButton(),
          Material(
            elevation: 6,
            type: MaterialType.circle,
            shadowColor: style.colors.onBackgroundOpacity27,
            color: style.colors.onPrimary,
            child: Center(
              child: AvatarWidget.fromRxChat(
                c.chat,
                radius: AvatarRadius.medium,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            c.chat!.title.value,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Obx(() {
                          if (c.chat?.chat.value.muted == null) {
                            return const SizedBox();
                          }

                          return const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: SvgIcon(SvgIcons.muted),
                          );
                        }),
                      ],
                    );
                  }),
                  if (!c.isMonolog && c.chat != null)
                    ChatSubtitle(c.chat!, c.me),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40),
          if (c.editing.value) ...[
            AnimatedButton(
              onPressed: c.editing.toggle,
              decorator: (child) => Padding(
                padding: const EdgeInsets.only(right: 18),
                child: child,
              ),
              child: const SvgIcon(SvgIcons.closePrimary),
            ),
          ] else ...[
            // AnimatedButton(
            //   onPressed: () => router.chat(c.chat?.id ?? id),
            //   child: const SvgIcon(SvgIcons.chat),
            // ),
            AnimatedButton(
              key: const Key('EditButton'),
              decorator: (child) => Padding(
                padding: const EdgeInsets.fromLTRB(19, 8, 19, 8),
                child: child,
              ),
              onPressed: c.editing.toggle,
              child: const SvgIcon(SvgIcons.edit22),
            ),
            // KeyedSubtree(
            //   key: const Key('MoreButton'),
            //   child: ContextMenuRegion(
            //     key: c.moreKey,
            //     selector: c.moreKey,
            //     alignment: Alignment.topRight,
            //     enablePrimaryTap: true,
            //     margin: const EdgeInsets.only(bottom: 4, left: 20),
            //     actions: [
            //       ContextMenuButton(
            //         label: 'btn_audio_call'.l10n,
            //         onPressed: hasCall ? null : () => c.call(false),
            //         trailing: hasCall
            //             ? const SvgIcon(SvgIcons.makeAudioCallDisabled)
            //             : const SvgIcon(SvgIcons.makeAudioCall),
            //         inverted: const SvgIcon(SvgIcons.makeAudioCallWhite),
            //       ),
            //       ContextMenuButton(
            //         label: 'btn_video_call'.l10n,
            //         onPressed: hasCall ? null : () => c.call(true),
            //         trailing: Transform.translate(
            //           offset: const Offset(2, 0),
            //           child: hasCall
            //               ? const SvgIcon(SvgIcons.makeVideoCallDisabled)
            //               : const SvgIcon(SvgIcons.makeVideoCall),
            //         ),
            //         inverted: Transform.translate(
            //           offset: const Offset(2, 0),
            //           child: const SvgIcon(SvgIcons.makeVideoCallWhite),
            //         ),
            //       ),
            //       ContextMenuButton(
            //         key: const Key('EditButton'),
            //         label: 'btn_edit'.l10n,
            //         onPressed: c.editing.toggle,
            //         trailing: const SvgIcon(SvgIcons.edit),
            //         inverted: const SvgIcon(SvgIcons.editWhite),
            //       ),
            //       ContextMenuButton(
            //         label: favorite
            //             ? 'btn_delete_from_favorites'.l10n
            //             : 'btn_add_to_favorites'.l10n,
            //         onPressed: favorite ? c.unfavoriteChat : c.favoriteChat,
            //         trailing: SvgIcon(
            //           favorite
            //               ? SvgIcons.favoriteSmall
            //               : SvgIcons.unfavoriteSmall,
            //         ),
            //         inverted: SvgIcon(
            //           favorite
            //               ? SvgIcons.favoriteSmallWhite
            //               : SvgIcons.unfavoriteSmallWhite,
            //         ),
            //       ),
            //     ],
            //     child: Container(
            //       padding: const EdgeInsets.only(left: 31, right: 25),
            //       height: double.infinity,
            //       child: const SvgIcon(SvgIcons.more),
            //     ),
            //   ),
            // ),
          ],
        ],
      ),
    );
  }

  Widget _quick(ChatInfoController c, BuildContext context) {
    final style = Theme.of(context).style;

    Widget button({
      required SvgData icon,
      required String label,
      void Function()? onPressed,
    }) {
      return WidgetButton(
        onPressed: onPressed,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: style.cardColor,
            border: style.cardBorder,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgIcon(icon),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: FittedBox(
                      child: Text(
                        label,
                        style: style.fonts.small.regular.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SelectionContainer.disabled(
      child: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          constraints:
              context.isNarrow ? null : const BoxConstraints(maxWidth: 400),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: button(
                  label: 'label_chat'.l10n,
                  icon: SvgIcons.chat,
                  onPressed: () => router.chat(id),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: button(
                  label: 'btn_audio'.l10n,
                  icon: SvgIcons.chatAudioCall,
                  onPressed: () => c.call(false),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: button(
                  label: 'btn_video'.l10n,
                  icon: SvgIcons.chatVideoCall,
                  onPressed: () => c.call(true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens a confirmation popup leaving this [Chat].
  Future<void> _leaveGroup(ChatInfoController c, BuildContext context) async {
    final bool? result = await MessagePopup.alert(
      'label_leave_group'.l10n,
      description: [TextSpan(text: 'alert_you_will_leave_group'.l10n)],
    );

    if (result == true) {
      await c.removeChatMember(c.me!);
    }
  }

  /// Opens a confirmation popup hiding this [Chat].
  Future<void> _hideChat(ChatInfoController c, BuildContext context) async {
    final style = Theme.of(context).style;

    final bool? result = await MessagePopup.alert(
      'label_delete_chat'.l10n,
      description: [
        TextSpan(text: 'alert_chat_will_be_deleted1'.l10n),
        TextSpan(
            text: c.chat?.title.value,
            style: style.fonts.normal.regular.onBackground),
        TextSpan(text: 'alert_chat_will_be_deleted2'.l10n),
      ],
    );

    if (result == true) {
      await c.hideChat();
    }
  }

  /// Opens a confirmation popup clearing this [Chat].
  Future<void> _clearChat(ChatInfoController c, BuildContext context) async {
    final style = Theme.of(context).style;

    final bool? result = await MessagePopup.alert(
      'label_clear_history'.l10n,
      description: [
        TextSpan(text: 'alert_chat_will_be_cleared1'.l10n),
        TextSpan(
            text: c.chat?.title.value,
            style: style.fonts.normal.regular.onBackground),
        TextSpan(text: 'alert_chat_will_be_cleared2'.l10n),
      ],
    );

    if (result == true) {
      await c.clearChat();
    }
  }

  /// Opens a confirmation popup blacklisting this [Chat].
  Future<void> _blacklistChat(
    ChatInfoController c,
    BuildContext context,
  ) async {
    final style = Theme.of(context).style;

    final bool? result = await MessagePopup.alert(
      'label_block'.l10n,
      description: [
        TextSpan(text: 'alert_chat_will_be_blocked1'.l10n),
        TextSpan(
            text: c.chat?.title.value,
            style: style.fonts.normal.regular.onBackground),
        TextSpan(text: 'alert_chat_will_be_blocked2'.l10n),
      ],
    );

    if (result == true) {
      // TODO: Blacklist this [Chat].
    }
  }
}

class BigButton extends StatefulWidget {
  const BigButton({
    super.key,
    this.onPressed,
    required this.title,
    this.leading,
  });

  final Widget? leading;
  final Widget title;
  final void Function()? onPressed;

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return MouseRegion(
      opaque: false,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        height: 56,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: style.cardRadius,
            border: style.cardBorder,
            color: style.colors.transparent,
          ),
          child: Material(
            type: MaterialType.card,
            borderRadius: style.cardRadius,
            // color: style.cardColor.darken(0.05),
            color: style.cardColor,
            child: InkWell(
              borderRadius: style.cardRadius,
              onTap: widget.onPressed,
              hoverColor: style.cardColor.darken(0.08),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    Expanded(
                      child: DefaultTextStyle(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: style.fonts.normal.regular.secondary,
                        child: widget.title,
                      ),
                    ),
                    if (widget.leading != null) ...[
                      const SizedBox(width: 12),
                      DefaultTextStyle(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: style.fonts.normal.regular.onBackground.copyWith(
                          color: style.colors.primary,
                        ),
                        child: widget.leading!,
                      ),
                      // AnimatedScale(
                      //   duration: const Duration(milliseconds: 100),
                      //   scale: _hovered ? 1.05 : 1,
                      //   child: widget.leading!,
                      // ),
                      const SizedBox(width: 4),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
