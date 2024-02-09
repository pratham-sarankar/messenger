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

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/ui/page/home/page/my_profile/widget/background_preview.dart';
import 'package:messenger/ui/page/home/page/user/widget/contact_info.dart';
import 'package:messenger/ui/page/home/page/user/widget/copy_or_share.dart';
import 'package:messenger/ui/widget/animated_size_and_fade.dart';
import 'package:messenger/ui/widget/animated_switcher.dart';
import 'package:messenger/ui/widget/widget_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '/config.dart';
import '/domain/model/user.dart';
import '/l10n/l10n.dart';
import '/provider/gql/exceptions.dart' show CreateChatDirectLinkException;
import '/routes.dart';
import '/themes.dart';
import '/ui/page/home/page/my_profile/link_details/view.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import '/util/message_popup.dart';
import '/util/platform_utils.dart';

/// [ReactiveTextField] displaying the provided [link].
///
/// If [link] is `null`, generates and displays a random [ChatDirectLinkSlug].
class DirectLinkField extends StatefulWidget {
  const DirectLinkField(
    this.link, {
    super.key,
    this.onSubmit,
    this.transitions = true,
    this.background,
    this.generated,
  });

  /// Reactive state of the [ReactiveTextField].
  final ChatDirectLink? link;

  final String? generated;

  /// Callback, called when [ChatDirectLinkSlug] is submitted.
  final FutureOr<void> Function(ChatDirectLinkSlug?)? onSubmit;

  final bool transitions;
  final Uint8List? background;

  @override
  State<DirectLinkField> createState() => _DirectLinkFieldState();
}

/// State of an [DirectLinkField] maintaining the [_state].
class _DirectLinkFieldState extends State<DirectLinkField> {
  /// Generated [ChatDirectLinkSlug], used in the [_state], if any.
  String? _generated;

  /// State of the [ReactiveTextField].
  late final TextFieldState _state;

  bool _editing = false;
  bool _expanded = false;

  @override
  void initState() {
    if (widget.link == null) {
      _generated = widget.generated ?? ChatDirectLinkSlug.generate(10).val;
      // _editing = true;
    }

    _state = TextFieldState(
      text: widget.link?.slug.val ?? _generated,
      approvable: true,
      submitted: widget.link != null,
      onChanged: (s) {
        s.error.value = null;

        try {
          ChatDirectLinkSlug(s.text);
        } on FormatException {
          s.error.value = 'err_incorrect_input'.l10n;
        }
      },
      onSubmitted: (s) async {
        ChatDirectLinkSlug? slug;
        try {
          slug = ChatDirectLinkSlug(s.text);
        } on FormatException {
          s.error.value = 'err_incorrect_input'.l10n;
        }

        setState(() => _editing = false);

        if (slug == null || slug == widget.link?.slug) {
          return;
        }

        if (s.error.value == null) {
          s.editable.value = false;
          s.status.value = RxStatus.loading();

          try {
            await widget.onSubmit?.call(slug);
            s.status.value = RxStatus.success();
            await Future.delayed(const Duration(seconds: 1));
            s.status.value = RxStatus.empty();
          } on CreateChatDirectLinkException catch (e) {
            s.status.value = RxStatus.empty();
            s.error.value = e.toMessage();
          } catch (e) {
            s.status.value = RxStatus.empty();
            MessagePopup.error(e);
            s.unsubmit();
            rethrow;
          } finally {
            s.editable.value = true;
          }
        }
      },
    );

    super.initState();
  }

  @override
  void didUpdateWidget(DirectLinkField oldWidget) {
    if (!_state.focus.hasFocus &&
        !_state.changed.value &&
        _state.editable.value) {
      _state.unchecked = widget.link?.slug.val;

      if (oldWidget.link != widget.link) {
        _editing = widget.link == null;
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    final Widget child;

    if (_editing) {
      child = Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ReactiveTextField(
          key: const Key('LinkField'),
          state: _state,
          onSuffixPressed: _state.isEmpty.value || !widget.transitions
              ? null
              : () {
                  _state.submit();

                  final share = '${Config.link}/${_state.text}';

                  if (PlatformUtils.isMobile) {
                    Share.share(share);
                  } else {
                    PlatformUtils.copy(text: share);
                    MessagePopup.success('label_copied'.l10n);
                  }
                },
          trailing: _state.isEmpty.value || !widget.transitions
              ? null
              : PlatformUtils.isMobile
                  ? const SvgIcon(SvgIcons.share)
                  : const SvgIcon(SvgIcons.copy),
          label: '${Config.link}/',
          // subtitle: false && widget.transitions
          //     ? RichText(
          //         text: TextSpan(
          //           style: style.fonts.small.regular.onBackground,
          //           children: [
          //             TextSpan(
          //               text: 'label_transition_count'.l10nfmt({
          //                     'count': widget.link?.usageCount ?? 0,
          //                   }) +
          //                   'dot_space'.l10n,
          //               style: style.fonts.small.regular.secondary,
          //             ),
          //             // TextSpan(
          //             //   text: 'label_details'.l10n,
          //             //   style: style.fonts.small.regular.primary,
          //             //   recognizer: TapGestureRecognizer()
          //             //     ..onTap = () => LinkDetailsView.show(context),
          //             // ),
          //           ],
          //         ),
          //       )
          //     : null,
        ),
      );
    } else {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: style.primaryBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: widget.background == null
                        ? const SvgImage.asset(
                            'assets/images/background_light.svg',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.memory(widget.background!, fit: BoxFit.cover),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 14),
                  _info(context, Text(DateTime.now().yMd)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(48, 0, 0, 0),
                    child: WidgetButton(
                      onPressed: () {
                        final share = '${Config.link}/${_state.text}';

                        if (PlatformUtils.isMobile) {
                          Share.share(share);
                        } else {
                          PlatformUtils.copy(text: share);
                          MessagePopup.success(
                            'label_copied'.l10n,
                          );
                        }
                      },
                      child: MessagePreviewWidget(
                        fromMe: true,
                        style: style.fonts.medium.regular.primary,
                        child: Stack(
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${Config.link}/${_state.text}',
                                    style: style.fonts.medium.regular.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(48, 0, 6, 0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: style.secondaryBorder,
                          color: style.readMessageColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: QrImageView(
                          data: '${Config.link}/${_state.text}',
                          version: QrVersions.auto,
                          size: 300.0,
                        ),
                      ),
                    ),
                  ),
                  if (widget.transitions)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 0, 0, 0),
                      child: MessagePreviewWidget(
                        fromMe: true,
                        text: '${widget.link?.usageCount ?? 0} кликов',
                        style: style.fonts.medium.regular.secondary,
                        // primary: true,
                      ),
                    ),
                  const SizedBox(height: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: PlatformUtils.isMobile
                            ? 'Поделиться'
                            : 'Копировать',
                        style: style.fonts.small.regular.primary,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            final share = '${Config.link}/${_state.text}';

                            if (PlatformUtils.isMobile) {
                              Share.share(share);
                            } else {
                              PlatformUtils.copy(text: share);
                              MessagePopup.success('label_copied'.l10n);
                            }
                          },
                      ),
                      // TextSpan(
                      //   text: ' | ',
                      //   style: style.fonts.small.regular.secondary,
                      // ),
                      // TextSpan(
                      //   text: 'label_transition_count'.l10nfmt({
                      //     'count': widget.link?.usageCount ?? 0,
                      //   }), //+
                      //   // 'dot_space'.l10n,
                      //   style: style.fonts.small.regular.primary,
                      // ),
                      // TextSpan(
                      //   text: 'label_details'.l10n,
                      //   style: style.fonts.small.regular.primary,
                      //   recognizer: TapGestureRecognizer()
                      //     ..onTap = () => LinkDetailsView.show(context),
                      // ),
                    ],
                  ),
                  textAlign: widget.onSubmit == null
                      ? TextAlign.center
                      : TextAlign.left,
                ),
              ),
              if (widget.onSubmit != null) ...[
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Удалить',
                        style: widget.onSubmit == null
                            ? style.fonts.small.regular.secondary
                            : style.fonts.small.regular.primary,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              widget.onSubmit?.call(null);
                              _state.unsubmit();
                              _state.changed.value = true;
                              _editing = true;
                            });
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    final animated = AnimatedSizeAndFade(
      sizeDuration: const Duration(milliseconds: 300),
      fadeDuration: const Duration(milliseconds: 300),
      child: child,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        animated,
        // Stack(
        //   children: [
        //     Positioned.fill(
        //       child: widget.background == null
        //           ? const SvgImage.asset(
        //               'assets/images/background_light.svg',
        //               width: double.infinity,
        //               height: double.infinity,
        //               fit: BoxFit.cover,
        //             )
        //           : Image.memory(
        //               widget.background!,
        //               fit: BoxFit.cover,
        //             ),
        //     ),
        //     animated,
        //   ],
        // ),

        // const SizedBox(height: 16),
        // WidgetButton(
        //   onPressed: () => setState(() => _expanded = !_expanded),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: Container(
        //           width: double.infinity,
        //           height: 0.5,
        //           color: style.colors.primary,
        //         ),
        //       ),
        //       const SizedBox(width: 8),
        //       Text(
        //         _expanded ? 'Скрыть' : 'Ещё',
        //         style: style.fonts.small.regular.primary,
        //       ),
        //       const SizedBox(width: 8),
        //       Expanded(
        //         child: Container(
        //           width: double.infinity,
        //           height: 0.5,
        //           color: style.colors.primary,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _info(BuildContext context, Widget child) {
    final style = Theme.of(context).style;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: style.systemMessageBorder,
            color: style.systemMessageColor,
          ),
          child: DefaultTextStyle(
            style: style.systemMessageStyle,
            child: child,
          ),
        ),
      ),
    );
  }
}
