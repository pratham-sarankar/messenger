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

import 'dart:math';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:messenger/domain/model/attachment.dart';
import 'package:messenger/domain/model/chat_item.dart';
import 'package:messenger/domain/model/precise_date_time/precise_date_time.dart';
import 'package:messenger/ui/page/call/widget/fit_view.dart';
import 'package:messenger/ui/page/home/page/chat/get_paid/controller.dart';
import 'package:messenger/ui/page/home/page/chat/get_paid/view.dart';
import 'package:messenger/ui/page/home/page/chat/widget/chat_gallery.dart';
import 'package:messenger/ui/page/home/page/chat/widget/chat_item.dart';
import 'package:messenger/ui/page/login/qr_code/view.dart';
import 'package:messenger/ui/widget/animated_button.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../chat/message_field/view.dart';
import '/api/backend/schema.dart' show Presence;
import '/domain/model/cache_info.dart';
import '/domain/model/my_user.dart';
import '/domain/model/ongoing_call.dart';
import '/domain/model/user.dart';
import '/domain/repository/settings.dart';
import '/l10n/l10n.dart';
import '/routes.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/widget/back_button.dart';
import '/ui/page/home/tab/menu/status/view.dart';
import '/ui/page/home/widget/app_bar.dart';
import '/ui/page/home/widget/big_avatar.dart';
import '/ui/page/home/widget/block.dart';
import '/ui/page/home/widget/confirm_dialog.dart';
import '/ui/page/home/widget/direct_link.dart';
import '/ui/page/home/widget/field_button.dart';
import '/ui/page/home/widget/num.dart';
import '/ui/page/home/widget/paddings.dart';
import '/ui/widget/progress_indicator.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import '/ui/widget/widget_button.dart';
import '/ui/worker/cache.dart';
import '/util/media_utils.dart';
import '/util/message_popup.dart';
import '/util/platform_utils.dart';
import 'add_email/view.dart';
import 'add_phone/view.dart';
import 'blacklist/view.dart';
import 'call_window_switch/view.dart';
import 'camera_switch/view.dart';
import 'controller.dart';
import 'language/view.dart';
import 'microphone_switch/view.dart';
import 'output_switch/view.dart';
import 'paid_list/view.dart';
import 'password/view.dart';
import 'timeline_switch/view.dart';
import 'welcome_message/view.dart';
import 'widget/background_preview.dart';
import 'widget/download_button.dart';
import 'widget/login.dart';
import 'widget/name.dart';
import 'widget/status.dart';
import 'widget/switch_field.dart';

/// View of the [Routes.me] page.
class MyProfileView extends StatelessWidget {
  const MyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      key: const Key('MyProfileView'),
      init: MyProfileController(Get.find(), Get.find(), Get.find()),
      global: !Get.isRegistered<MyProfileController>(),
      builder: (MyProfileController c) {
        return GestureDetector(
          onTap: FocusManager.instance.primaryFocus?.unfocus,
          child: Scaffold(
            appBar: CustomAppBar(
              title: Text('label_account'.l10n),
              padding: const EdgeInsets.only(left: 4, right: 20),
              leading: const [StyledBackButton()],
              actions: [
                AnimatedButton(
                  onPressed: () {},
                  child: SvgImage.asset(
                    'assets/icons/search.svg',
                    width: 17.77,
                  ),
                ),
              ],
            ),
            body: Scrollbar(
              controller: c.scrollController,
              child: ScrollablePositionedList.builder(
                key: const Key('MyProfileScrollable'),
                initialScrollIndex: c.listInitIndex,
                scrollController: c.scrollController,
                itemScrollController: c.itemScrollController,
                itemPositionsListener: c.positionsListener,
                itemCount: ProfileTab.values.length,
                itemBuilder: (context, i) {
                  switch (ProfileTab.values[i]) {
                    case ProfileTab.public:
                      return Block(
                        title: 'label_profile'.l10n,
                        children: [
                          Obx(() {
                            return BigAvatarWidget.myUser(
                              c.myUser.value,
                              loading: c.avatarUpload.value.isLoading,
                              onUpload: c.uploadAvatar,
                              onDelete: c.myUser.value?.avatar != null
                                  ? c.deleteAvatar
                                  : null,
                            );
                          }),
                          const SizedBox(height: 12),
                          Paddings.basic(
                            Obx(() {
                              return UserNameField(
                                c.myUser.value?.name,
                                onSubmit: c.updateUserName,
                              );
                            }),
                          ),
                          _presence(context, c),
                          Paddings.basic(
                            Obx(() {
                              return UserTextStatusField(
                                c.myUser.value?.status,
                                onSubmit: c.updateUserStatus,
                              );
                            }),
                          )
                        ],
                      );

                    case ProfileTab.signing:
                      return Block(
                        title: 'label_login_options'.l10n,
                        children: [
                          Paddings.basic(
                            Obx(() => UserNumCopyable(c.myUser.value?.num)),
                          ),
                          Paddings.basic(
                            Obx(() {
                              return UserLoginField(
                                c.myUser.value?.login,
                                onSubmit: c.updateUserLogin,
                              );
                            }),
                          ),
                          _emails(context, c),
                          _phones(context, c),
                          _password(context, c),
                        ],
                      );

                    case ProfileTab.link:
                      return Block(
                        title: 'label_your_direct_link'.l10n,
                        children: [
                          Obx(() {
                            return DirectLinkField(
                              c.myUser.value?.chatDirectLink,
                              onSubmit: c.createChatDirectLink,
                            );
                          }),
                        ],
                      );

                    case ProfileTab.background:
                      return Block(
                        title: 'label_background'.l10n,
                        children: [
                          Paddings.dense(
                            Obx(() {
                              return BackgroundPreview(
                                c.background.value,
                                onPick: c.pickBackground,
                                onRemove: c.removeBackground,
                              );
                            }),
                          )
                        ],
                      );

                    case ProfileTab.chats:
                      return Block(
                        title: 'label_chats'.l10n,
                        children: [_chats(context, c)],
                      );

                    case ProfileTab.calls:
                      return Block(
                        title: 'label_calls'.l10n,
                        children: [_call(context, c)],
                      );

                    case ProfileTab.media:
                      if (PlatformUtils.isMobile) {
                        return const SizedBox();
                      }

                      return Block(
                        title: 'label_media'.l10n,
                        children: [_media(context, c)],
                      );

                    case ProfileTab.welcome:
                      return Block(
                        title: 'label_welcome_message'.l10n,
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        children: [_welcome(context, c)],
                      );

                    case ProfileTab.getPaid:
                      return Stack(
                        children: [
                          Block(
                            title: 'label_get_paid_for_incoming'.l10n,
                            children: [_getPaid(context, c)],
                          ),
                          Positioned.fill(
                            child: Obx(() {
                              return IgnorePointer(
                                ignoring: c.verified.value,
                                child: Center(
                                  child: AnimatedContainer(
                                    margin:
                                        const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                    duration: 200.milliseconds,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: c.verified.value
                                          ? const Color(0x00000000)
                                          : const Color(0x0A000000),
                                    ),
                                    constraints: context.isNarrow
                                        ? null
                                        : const BoxConstraints(maxWidth: 400),
                                  ),
                                ),
                              );
                            }),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Obx(() {
                                return AnimatedSwitcher(
                                  duration: 200.milliseconds,
                                  child: c.verified.value
                                      ? const SizedBox()
                                      : Container(
                                          key: const Key('123'),
                                          alignment: Alignment.bottomCenter,
                                          padding: const EdgeInsets.fromLTRB(
                                            32,
                                            16,
                                            32,
                                            16,
                                          ),
                                          margin: const EdgeInsets.fromLTRB(
                                              8, 4, 8, 4),
                                          constraints: context.isNarrow
                                              ? null
                                              : const BoxConstraints(
                                                  maxWidth: 400),
                                          child: Column(
                                            children: [
                                              const Spacer(),
                                              _verification(context, c),
                                            ],
                                          ),
                                        ),
                                );
                              }),
                            ),
                          ),
                        ],
                      );

                    case ProfileTab.donates:
                      return Stack(
                        children: [
                          Block(
                            title: 'label_donates'.l10n,
                            children: [_donates(context, c)],
                          ),
                          Positioned.fill(
                            child: Obx(() {
                              return IgnorePointer(
                                ignoring: c.verified.value,
                                child: Center(
                                  child: AnimatedContainer(
                                    margin:
                                        const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                    duration: 200.milliseconds,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: c.verified.value
                                          ? const Color(0x00000000)
                                          : const Color(0x0A000000),
                                    ),
                                    constraints: context.isNarrow
                                        ? null
                                        : const BoxConstraints(maxWidth: 400),
                                  ),
                                ),
                              );
                            }),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Obx(() {
                                return AnimatedSwitcher(
                                  duration: 200.milliseconds,
                                  child: c.verified.value
                                      ? const SizedBox()
                                      : Container(
                                          key: const Key('123'),
                                          alignment: Alignment.bottomCenter,
                                          padding: const EdgeInsets.fromLTRB(
                                            32,
                                            16,
                                            32,
                                            16,
                                          ),
                                          margin: const EdgeInsets.fromLTRB(
                                            8,
                                            4,
                                            8,
                                            4,
                                          ),
                                          constraints: context.isNarrow
                                              ? null
                                              : const BoxConstraints(
                                                  maxWidth: 400,
                                                ),
                                          child: Column(
                                            children: [
                                              const Spacer(),
                                              _verification(context, c),
                                            ],
                                          ),
                                        ),
                                );
                              }),
                            ),
                          ),
                        ],
                      );

                    case ProfileTab.notifications:
                      return Block(
                        title: 'label_audio_notifications'.l10n,
                        children: [
                          Paddings.dense(
                            Obx(() {
                              final bool isMuted =
                                  c.myUser.value?.muted == null;

                              return SwitchField(
                                text: isMuted
                                    ? 'label_enabled'.l10n
                                    : 'label_disabled'.l10n,
                                value: isMuted,
                                onChanged:
                                    c.isMuting.value ? null : c.toggleMute,
                              );
                            }),
                          )
                        ],
                      );

                    case ProfileTab.storage:
                      return Block(
                        title: 'label_storage'.l10n,
                        children: [_storage(context, c)],
                      );

                    case ProfileTab.language:
                      return Block(
                        title: 'label_language'.l10n,
                        children: [_language(context, c)],
                      );

                    case ProfileTab.blacklist:
                      return Block(
                        title: 'label_blocked_users'.l10n,
                        children: [_blockedUsers(context, c)],
                      );

                    case ProfileTab.devices:
                      return Block(
                        title: 'label_linked_devices'.l10n,
                        children: [_devices(context, c)],
                      );

                    case ProfileTab.download:
                      if (!PlatformUtils.isWeb) {
                        return const SizedBox();
                      }

                      return Block(
                        title: 'label_download_application'.l10n,
                        children: [_downloads(context, c)],
                      );

                    case ProfileTab.danger:
                      return Block(
                        title: 'label_danger_zone'.l10n,
                        children: [_danger(context, c)],
                      );

                    case ProfileTab.vacancies:
                      return const SizedBox();

                    case ProfileTab.styles:
                      return const SizedBox();

                    case ProfileTab.logout:
                      return const SizedBox();
                  }
                },
              ),
            ),
            floatingActionButton: Obx(() {
              if (c.myUser.value != null) {
                return const SizedBox();
              }

              return const CustomProgressIndicator();
            }),
          ),
        );
      },
    );
  }
}

/// Basic [Padding] wrapper.
Widget _padding(Widget child) =>
    Padding(padding: const EdgeInsets.all(8), child: child);

/// Dense [Padding] wrapper.
Widget _dense(Widget child) =>
    Padding(padding: const EdgeInsets.fromLTRB(8, 4, 8, 4), child: child);

/// Returns addable list of [MyUser.emails].
Widget _emails(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Obx(() {
    final List<Widget> widgets = [];

    for (UserEmail e in c.myUser.value?.emails.confirmed ?? []) {
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FieldButton(
              key: const Key('ConfirmedEmail'),
              text: e.val,
              hint: 'label_email'.l10n,
              onPressed: () {
                PlatformUtils.copy(text: e.val);
                MessagePopup.success('label_copied'.l10n);
              },
              onTrailingPressed: () => _deleteEmail(c, context, e),
              trailing: Transform.translate(
                key: const Key('DeleteEmail'),
                offset: const Offset(0, -1),
                child: Transform.scale(
                  scale: 1.15,
                  child: SvgImage.asset('assets/icons/delete.svg', height: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'label_email_visible'.l10n,
                      style: style.fonts.bodySmall.copyWith(
                        color: style.colors.secondary,
                      ),
                    ),
                    TextSpan(
                      text: 'label_nobody'.l10n.toLowerCase() + 'dot'.l10n,
                      style: style.fonts.bodySmall.copyWith(
                        color: style.colors.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await ConfirmDialog.show(
                            context,
                            title: 'label_email'.l10n,
                            additional: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'label_visible_to'.l10n,
                                  style: style.fonts.headlineMedium,
                                ),
                              ),
                            ],
                            label: 'label_confirm'.l10n,
                            initial: 2,
                            variants: [
                              ConfirmDialogVariant(
                                onProceed: () {},
                                child: Text('label_all'.l10n),
                              ),
                              ConfirmDialogVariant(
                                onProceed: () {},
                                child: Text('label_my_contacts'.l10n),
                              ),
                              ConfirmDialogVariant(
                                onProceed: () {},
                                child: Text('label_nobody'.l10n),
                              ),
                            ],
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    if (c.myUser.value?.emails.unconfirmed != null) {
      widgets.addAll([
        Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme:
                Theme.of(context).inputDecorationTheme.copyWith(
                      floatingLabelStyle: style.fonts.bodyMedium.copyWith(
                        color: style.colors.primary,
                      ),
                    ),
          ),
          child: FieldButton(
            key: const Key('UnconfirmedEmail'),
            text: c.myUser.value!.emails.unconfirmed!.val,
            hint: 'label_verify_email'.l10n,
            trailing: Transform.translate(
              offset: const Offset(0, -1),
              child: Transform.scale(
                scale: 1.15,
                child: SvgImage.asset('assets/icons/delete.svg', height: 14),
              ),
            ),
            onPressed: () => AddEmailView.show(
              context,
              email: c.myUser.value!.emails.unconfirmed!,
            ),
            onTrailingPressed: () => _deleteEmail(
              c,
              context,
              c.myUser.value!.emails.unconfirmed!,
            ),
            style:
                style.fonts.titleMedium.copyWith(color: style.colors.primary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'E-mail не верифицирован. '.l10n,
                  style: style.fonts.bodySmall.copyWith(
                    fontSize: 11,
                    color: style.colors.dangerColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]);
      widgets.add(const SizedBox(height: 8));
    }

    if (c.myUser.value?.emails.unconfirmed == null) {
      widgets.add(
        FieldButton(
          key: c.myUser.value?.emails.confirmed.isNotEmpty == true
              ? const Key('AddAdditionalEmail')
              : const Key('AddEmail'),
          text: c.myUser.value?.emails.confirmed.isNotEmpty == true
              ? 'label_add_additional_email'.l10n
              : 'label_add_email'.l10n,
          border: c.myUser.value?.emails.confirmed.isEmpty == true &&
                  c.myUser.value?.emails.unconfirmed == null
              ? style.colors.dangerColor
              : null,
          onPressed: () => AddEmailView.show(context),
          style: style.fonts.titleMedium.copyWith(color: style.colors.primary),
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets.map((e) => _dense(e)).toList(),
    );
  });
}

/// Returns addable list of [MyUser.emails].
Widget _phones(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Obx(() {
    final List<Widget> widgets = [];

    for (UserPhone e in [...c.myUser.value?.phones.confirmed ?? []]) {
      widgets.add(
        Column(
          key: const Key('ConfirmedPhone'),
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FieldButton(
              text: e.val,
              hint: 'label_phone_number'.l10n,
              trailing: Transform.translate(
                key: const Key('DeletePhone'),
                offset: const Offset(0, -5),
                child: Transform.scale(
                  scale: 1.15,
                  child: SvgImage.asset('assets/icons/delete.svg', height: 14),
                ),
              ),
              onPressed: () {
                PlatformUtils.copy(text: e.val);
                MessagePopup.success('label_copied'.l10n);
              },
              onTrailingPressed: () => _deletePhone(c, context, e),
              subtitle: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'label_phone_visible'.l10n,
                      style: style.fonts.labelMediumSecondary,
                    ),
                    TextSpan(
                      text: 'label_nobody'.l10n.toLowerCase() + 'dot'.l10n,
                      style: style.fonts.labelMediumPrimary,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await ConfirmDialog.show(
                            context,
                            title: 'label_phone'.l10n,
                            additional: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'label_visible_to'.l10n,
                                  style: style.fonts.headlineMedium,
                                ),
                              ),
                            ],
                            label: 'label_confirm'.l10n,
                            initial: 2,
                            variants: [
                              ConfirmDialogVariant(
                                onProceed: () {},
                                child: Text('label_all'.l10n),
                              ),
                              ConfirmDialogVariant(
                                onProceed: () {},
                                child: Text('label_my_contacts'.l10n),
                              ),
                              ConfirmDialogVariant(
                                onProceed: () {},
                                child: Text('label_nobody'.l10n),
                              ),
                            ],
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    if (c.myUser.value?.phones.unconfirmed != null) {
      widgets.addAll([
        Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme:
                Theme.of(context).inputDecorationTheme.copyWith(
                      floatingLabelStyle: style.fonts.bodyMedium.copyWith(
                        color: style.colors.primary,
                      ),
                    ),
          ),
          child: FieldButton(
            key: const Key('UnconfirmedPhone'),
            text: c.myUser.value!.phones.unconfirmed!.val,
            hint: 'label_verify_number'.l10n,
            trailing: Transform.translate(
              offset: const Offset(0, -1),
              child: Transform.scale(
                scale: 1.15,
                child: SvgImage.asset('assets/icons/delete.svg', height: 14),
              ),
            ),
            onPressed: () => AddPhoneView.show(
              context,
              phone: c.myUser.value!.phones.unconfirmed!,
            ),
            onTrailingPressed: () => _deletePhone(
              c,
              context,
              c.myUser.value!.phones.unconfirmed!,
            ),
            style:
                style.fonts.titleMedium.copyWith(color: style.colors.secondary),
          ),
        ),
      ]);
      widgets.add(const SizedBox(height: 8));
    }

    if (c.myUser.value?.phones.unconfirmed == null) {
      widgets.add(
        FieldButton(
          key: c.myUser.value?.phones.confirmed.isNotEmpty == true
              ? const Key('AddAdditionalPhone')
              : const Key('AddPhone'),
          onPressed: () => AddPhoneView.show(context),
          text: c.myUser.value?.phones.confirmed.isNotEmpty == true
              ? 'label_add_additional_number'.l10n
              : 'label_add_number'.l10n,
          border: c.myUser.value?.emails.confirmed.isEmpty == true &&
                  c.myUser.value?.emails.unconfirmed == null
              ? style.colors.dangerColor
              : null,
          style: style.fonts.titleMedium.copyWith(color: style.colors.primary),
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets.map((e) => Paddings.dense(e)).toList(),
    );
  });
}

/// Returns [WidgetButton] displaying the [MyUser.presence].
Widget _presence(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Obx(() {
    final Presence? presence = c.myUser.value?.presence;

    return Paddings.basic(
      FieldButton(
        onPressed: () => StatusView.show(context, expanded: false),
        hint: 'label_presence'.l10n,
        text: presence?.localizedString(),
        trailing:
            CircleAvatar(backgroundColor: presence?.getColor(), radius: 7),
        style: style.fonts.titleMediumPrimary,
      ),
    );
  });
}

/// Returns the buttons changing or setting the password of the currently
/// authenticated [MyUser].
Widget _password(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _dense(
        FieldButton(
          key: c.myUser.value?.hasPassword == true
              ? const Key('ChangePassword')
              : const Key('SetPassword'),
          text: c.myUser.value?.hasPassword == true
              ? 'btn_change_password'.l10n
              : 'btn_set_password'.l10n,
          onPressed: () => ChangePasswordView.show(context),
          border: c.myUser.value?.hasPassword != true
              ? style.colors.dangerColor
              : null,
          style: style.fonts.titleMedium.copyWith(
            color: style.colors.primary,
          ),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}

/// Returns the contents of a [ProfileTab.danger] section.
Widget _danger(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Column(
    children: [
      _dense(
        FieldButton(
          key: const Key('DeleteAccount'),
          text: 'btn_delete_account'.l10n,
          trailing: Transform.translate(
            offset: const Offset(0, -1),
            child: Transform.scale(
              scale: 1.15,
              child: SvgImage.asset('assets/icons/delete.svg', height: 14),
            ),
          ),
          onPressed: () => _deleteAccount(c, context),
          style: style.fonts.titleMedium.copyWith(color: style.colors.primary),
        ),
      ),
    ],
  );
}

/// Returns the contents of a [ProfileTab.background] section.
Widget _background(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  Widget message({
    bool fromMe = true,
    bool isRead = true,
    String text = '123',
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5 * 2, 6, 5 * 2, 6),
      child: IntrinsicWidth(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            color: fromMe
                ? isRead
                    ? style.readMessageColor
                    : style.unreadMessageColor
                : style.messageColor,
            borderRadius: BorderRadius.circular(15),
            border: fromMe
                ? isRead
                    ? style.secondaryBorder
                    : Border.all(
                        color: style.colors.backgroundAuxiliaryLighter,
                        width: 0.5,
                      )
                : style.primaryBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                child: Text(text, style: style.fonts.bodyLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }

  return _dense(
    Column(
      children: [
        WidgetButton(
          onPressed: c.pickBackground,
          child: Container(
            decoration: BoxDecoration(
              border: style.primaryBorder,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(() {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: c.background.value == null
                            ? SvgImage.asset(
                                'assets/images/background_light.svg',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.memory(
                                c.background.value!,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: message(
                                fromMe: false,
                                text: 'label_hello'.l10n,
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: message(
                                fromMe: true,
                                text: 'label_hello_reply'.l10n,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        Obx(() {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WidgetButton(
                    onPressed: c.background.value == null
                        ? c.pickBackground
                        : c.removeBackground,
                    child: Text(
                      c.background.value == null
                          ? 'btn_upload'.l10n
                          : 'btn_delete'.l10n,
                      style:
                          TextStyle(color: style.colors.primary, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ),
  );
}

/// Returns the contents of a [ProfileTab.calls] section.
Widget _call(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (PlatformUtils.isDesktop && PlatformUtils.isWeb) ...[
        // if (PlatformUtils.isWeb) ...[
        _dense(
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 21.0),
              child: Text(
                'label_open_calls_in'.l10n,
                style: style.systemMessageStyle.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        _dense(
          Obx(() {
            return FieldButton(
              text: (c.settings.value?.enablePopups ?? true)
                  ? 'label_open_calls_in_window'.l10n
                  : 'label_open_calls_in_app'.l10n,
              maxLines: null,
              onPressed: () => CallWindowSwitchView.show(context),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
      // ],
      _dense(
        Stack(
          alignment: Alignment.centerRight,
          children: [
            IgnorePointer(
              child: ReactiveTextField(
                maxLines: null,
                state: TextFieldState(
                  text: 'label_leave_group_call_when_alone'.l10n,
                  editable: false,
                ),
                trailing: const SizedBox(width: 40),
                trailingWidth: 40,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Transform.scale(
                  scale: 0.7,
                  transformHitTests: false,
                  child: Theme(
                    data: ThemeData(platform: TargetPlatform.macOS),
                    child: Obx(
                      () => Switch.adaptive(
                        activeColor: Theme.of(context).colorScheme.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: c.settings.value?.leaveWhenAlone == true,
                        onChanged: c.setLeaveWhenAlone,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // _dense(
      //   Align(
      //     alignment: Alignment.centerLeft,
      //     child: Padding(
      //       padding: const EdgeInsets.only(left: 21.0),
      //       child: Text(
      //         'label_leave_group_call_when_alone'.l10n,
      //         style: style.systemMessageStyle.copyWith(
      //           color: Theme.of(context).colorScheme.secondary,
      //           fontSize: 15,
      //           fontWeight: FontWeight.w400,
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      // const SizedBox(height: 4),
      // _dense(
      //   Obx(() {
      //     return FieldButton(
      //       text: (c.settings.value?.leaveWhenAlone ?? false)
      //           ? 'label_leave_group_call_when_alone'.l10n
      //           : 'label_don_t_leave_group_call_when_alone'.l10n,
      //       maxLines: null,
      //       onPressed: () => CallLeaveSwitchView.show(context),
      //       style: TextStyle(color: Theme.of(context).colorScheme.primary),
      //     );
      //   }),
      // ),
    ],
  );
}

/// Returns the contents of a [ProfileTab.chats] section.
Widget _chats(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Paddings.dense(
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 21.0),
            child: Text(
              'label_display_timestamps'.l10n,
              style: style.systemMessageStyle.copyWith(
                color: style.colors.secondary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 4),
      Paddings.dense(
        Obx(() {
          return FieldButton(
            text: (c.settings.value?.timelineEnabled ?? true)
                ? 'label_as_timeline'.l10n
                : 'label_in_message'.l10n,
            maxLines: null,
            onPressed: () => TimelineSwitchView.show(context),
            style: TextStyle(color: style.colors.primary),
          );
        }),
      ),
    ],
  );
}

/// Returns the contents of a [ProfileTab.media] section.
Widget _media(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Paddings.dense(
        Obx(() {
          return FieldButton(
            text: (c.devices.video().firstWhereOrNull((e) =>
                            e.deviceId() == c.media.value?.videoDevice) ??
                        c.devices.video().firstOrNull)
                    ?.label() ??
                'label_media_no_device_available'.l10n,
            hint: 'label_media_camera'.l10n,
            onPressed: () async {
              await CameraSwitchView.show(
                context,
                camera: c.media.value?.videoDevice,
              );

              if (c.devices.video().isEmpty) {
                c.devices.value = await MediaUtils.enumerateDevices();
              }
            },
            style: style.fonts.titleMediumPrimary,
          );
        }),
      ),
      const SizedBox(height: 16),
      Paddings.dense(
        Obx(() {
          return FieldButton(
            text: (c.devices.audio().firstWhereOrNull((e) =>
                            e.deviceId() == c.media.value?.audioDevice) ??
                        c.devices.audio().firstOrNull)
                    ?.label() ??
                'label_media_no_device_available'.l10n,
            hint: 'label_media_microphone'.l10n,
            onPressed: () async {
              await MicrophoneSwitchView.show(
                context,
                mic: c.media.value?.audioDevice,
              );

              if (c.devices.audio().isEmpty) {
                c.devices.value = await MediaUtils.enumerateDevices();
              }
            },
            style: style.fonts.titleMediumPrimary,
          );
        }),
      ),
      const SizedBox(height: 16),
      Paddings.dense(
        Obx(() {
          return FieldButton(
            text: (c.devices.output().firstWhereOrNull((e) =>
                            e.deviceId() == c.media.value?.outputDevice) ??
                        c.devices.output().firstOrNull)
                    ?.label() ??
                'label_media_no_device_available'.l10n,
            hint: 'label_media_output'.l10n,
            onPressed: () async {
              await OutputSwitchView.show(
                context,
                output: c.media.value?.outputDevice,
              );

              if (c.devices.output().isEmpty) {
                c.devices.value = await MediaUtils.enumerateDevices();
              }
            },
            style: style.fonts.titleMediumPrimary,
          );
        }),
      ),
    ],
  );
}

Widget _welcome(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  final TextStyle? thin = Theme.of(context)
      .textTheme
      .bodyLarge
      ?.copyWith(color: style.colors.onBackground);

  Widget info({required Widget child}) {
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

  Widget message({
    String text = '123',
    List<Attachment> attachments = const [],
    PreciseDateTime? at,
  }) {
    final List<Attachment> media = attachments.where((e) {
      return ((e is ImageAttachment) ||
          (e is FileAttachment && e.isVideo) ||
          (e is LocalAttachment && (e.file.isImage || e.file.isVideo)));
    }).toList();

    final Iterable<GalleryAttachment> galleries =
        media.map((e) => GalleryAttachment(e, null));

    final List<Attachment> files = attachments.where((e) {
      return ((e is FileAttachment && !e.isVideo) ||
          (e is LocalAttachment && !e.file.isImage && !e.file.isVideo));
    }).toList();

    final bool timeInBubble = attachments.isNotEmpty;

    Widget? timeline;
    if (at != null) {
      timeline = SelectionContainer.disabled(
        child: Text(
          DateFormat.Hm().format(at.val.toLocal()),
          style: style.systemMessageStyle.copyWith(fontSize: 11),
        ),
        // child: Text(
        //   '${'label_date_ymd'.l10nfmt({
        //         'year': at.val.year.toString().padLeft(4, '0'),
        //         'month': at.val.month.toString().padLeft(2, '0'),
        //         'day': at.val.day.toString().padLeft(2, '0'),
        //       })}, 10:04',
        //   style: style.systemMessageStyle.copyWith(fontSize: 11),
        // ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(5 * 2, 6, 5 * 2, 6),
      child: Stack(
        children: [
          IntrinsicWidth(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: style.readMessageColor,
                borderRadius: BorderRadius.circular(15),
                border: style.secondaryBorder,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: text),
                            if (timeline != null)
                              WidgetSpan(
                                child: Opacity(opacity: 0, child: timeline),
                              ),
                          ],
                        ),
                        style: style.fonts.bodyLarge,
                      ),
                    ),
                  if (files.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: Column(
                        children: files
                            .map((e) => ChatItemWidget.fileAttachment(e))
                            .toList(),
                      ),
                    ),
                  if (media.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: text.isNotEmpty || files.isNotEmpty
                            ? Radius.zero
                            : files.isEmpty
                                ? const Radius.circular(15)
                                : Radius.zero,
                        topRight: text.isNotEmpty || files.isNotEmpty
                            ? Radius.zero
                            : files.isEmpty
                                ? const Radius.circular(15)
                                : Radius.zero,
                        bottomLeft: const Radius.circular(15),
                        bottomRight: const Radius.circular(15),
                      ),
                      child: media.length == 1
                          ? ChatItemWidget.mediaAttachment(
                              context,
                              media.first,
                              galleries,
                              filled: false,
                            )
                          : SizedBox(
                              width: media.length * 120,
                              height: max(media.length * 60, 300),
                              child: FitView(
                                dividerColor: Colors.transparent,
                                children: media
                                    .mapIndexed(
                                      (i, e) => ChatItemWidget.mediaAttachment(
                                        context,
                                        e,
                                        galleries,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                    ),
                ],
              ),
            ),
          ),
          if (timeline != null)
            Positioned(
              right: timeInBubble ? 4 : 8,
              bottom: 4,
              child: timeInBubble
                  ? Container(
                      padding: const EdgeInsets.only(
                        left: 5,
                        right: 5,
                        top: 2,
                        bottom: 2,
                      ),
                      decoration: BoxDecoration(
                        // color: Colors.white.withOpacity(0.9),
                        color: style.readMessageColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: timeline,
                    )
                  : timeline,
            )
        ],
      ),
    );
  }

  final Widget editOrDelete = info(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WidgetButton(
          onPressed: () async {
            c.send.editing.value = true;
            c.send.field.unchecked = c.welcome.value?.text?.val;
            c.send.attachments.value = c.welcome.value?.attachments
                    .map((e) => MapEntry(GlobalKey(), e))
                    .toList() ??
                [];

            // final ChatMessage? m = await WelcomeMessageView.show(
            //   context,
            //   initial: c.welcome.value,
            // );

            // if (m != null) {
            //   c.welcome.value = m;
            // }
          },
          child: Text(
            'btn_edit'.l10n,
            style: style.systemMessageStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
              // fontSize: 11,
            ),
          ),
        ),
        Text(
          'space_or_space'.l10n,
          style: style.systemMessageStyle,
        ),
        WidgetButton(
          key: const Key('DeleteAvatar'),
          onPressed: () => c.welcome.value = null,
          child: Text(
            'btn_delete'.l10n.toLowerCase(),
            style: style.systemMessageStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
              // fontSize: 11,
            ),
          ),
        ),
      ],
    ),
  );

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text('label_welcome_message_description'.l10n, style: thin),
      ),
      const SizedBox(height: 13),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: style.unreadMessageColor,
                  borderRadius: BorderRadius.only(
                    bottomRight: style.cardRadius.bottomRight,
                    bottomLeft: style.cardRadius.bottomLeft,
                  ),
                ),
              ),
              // child: ClipRRect(
              //   borderRadius: BorderRadius.only(
              //     bottomRight: style.cardRadius.bottomRight,
              //     bottomLeft: style.cardRadius.bottomLeft,
              //   ),
              //   // borderRadius: style.cardRadius,
              //   child: DecoratedBox(
              //     position: DecorationPosition.foreground,
              //     decoration: BoxDecoration(
              //         // color: style.sidebarColor,
              //         ),
              //     child: Obx(() {
              //       return c.background.value == null
              //           ? Container(
              //               child: SvgImage.asset(
              //                 'assets/images/background_light.svg',
              //                 width: double.infinity,
              //                 height: double.infinity,
              //                 fit: BoxFit.cover,
              //               ),
              //             )
              //           : Image.memory(
              //               c.background.value!,
              //               fit: BoxFit.cover,
              //             );

              //       // return c.background.value == null
              //       //     ? ImageFiltered(
              //       //         imageFilter:
              //       //             ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              //       //         child: Container(
              //       //           child: SvgImage.asset(
              //       //             'assets/images/background_light.svg',
              //       //             width: double.infinity,
              //       //             height: double.infinity,
              //       //             fit: BoxFit.cover,
              //       //           ),
              //       //         ),
              //       //       )
              //       //     : ImageFiltered(
              //       //         imageFilter:
              //       //             ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              //       //         child: Image.memory(
              //       //           c.background.value!,
              //       //           fit: BoxFit.cover,
              //       //         ),
              //       //       );
              //     }),
              //   ),
              // ),
            ),
            Obx(() {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  if (c.welcome.value == null)
                    WidgetButton(
                      onPressed: () async {
                        final ChatMessage? m = await WelcomeMessageView.show(
                          context,
                          initial: c.welcome.value,
                        );

                        if (m != null) {
                          c.welcome.value = m;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        height: 60 * 3,
                        child: info(
                          child: Text('label_no_welcome_message'.l10n),
                        ),
                      ),
                    )
                  else ...[
                    info(
                      child: Text(
                        c.welcome.value?.at.val.toRelative() ?? '',
                        // 'label_date_ymd'.l10nfmt({
                        //   'year': c.welcome.value?.at.val.year
                        //       .toString()
                        //       .padLeft(4, '0'),
                        //   'month': c.welcome.value?.at.val.month
                        //       .toString()
                        //       .padLeft(2, '0'),
                        //   'day': c.welcome.value?.at.val.day
                        //       .toString()
                        //       .padLeft(2, '0'),
                        // }),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: IgnorePointer(
                          child: message(
                            text: c.welcome.value?.text?.val ?? '',
                            attachments: c.welcome.value?.attachments ?? [],
                            at: c.welcome.value?.at,
                          ),
                        ),
                      ),
                    ),
                    editOrDelete,
                  ],
                  // const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: MessageFieldView(
                      fieldKey: const Key('ForwardField'),
                      sendKey: const Key('SendForward'),
                      constraints: const BoxConstraints(),
                      controller: c.send,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    ],
  );
}

Widget _verification(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Obx(() {
    return AnimatedSizeAndFade(
      fadeDuration: 300.milliseconds,
      sizeDuration: 300.milliseconds,
      child: c.verified.value
          ? const SizedBox(width: double.infinity)
          : Column(
              key: const Key('123'),
              children: [
                const SizedBox(height: 12 * 2),
                _dense(
                  Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme:
                          Theme.of(context).inputDecorationTheme.copyWith(
                                border: Theme.of(context)
                                    .inputDecorationTheme
                                    .border
                                    ?.copyWith(
                                      borderSide: c.hintVerified.value
                                          ? BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            )
                                          : Theme.of(context)
                                              .inputDecorationTheme
                                              .border
                                              ?.borderSide,
                                    ),
                              ),
                    ),
                    child: FieldButton(
                      text: 'btn_verify_email'.l10n,
                      // onPressed: () => c.verified.value = true,
                      onPressed: () async {
                        await AddEmailView.show(
                          context,
                          email: c.myUser.value?.emails.unconfirmed,
                        );
                      },
                      trailing: Icon(
                        Icons.verified_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 6),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                      children: [
                        TextSpan(
                          text:
                              'Данная опция доступна только для аккаунтов с верифицированным E-mail'
                                  .l10n,
                          style: TextStyle(color: style.colors.onBackground),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  });
}

Widget _getPaid(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  Widget title(String label, [bool enabled = true]) {
    return _dense(
      Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: style.systemMessageStyle.copyWith(
              // color: Theme.of(context).colorScheme.secondary,
              color:
                  enabled ? style.colors.onBackground : style.colors.secondary,
              fontSize: 15,

              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget field({
    required TextFieldState state,
    required String label,
    bool contacts = false,
    bool enabled = true,
  }) {
    return _padding(
      Stack(
        alignment: Alignment.centerLeft,
        children: [
          FieldButton(
            text: state.text,
            prefixText: '    ',
            prefixStyle: const TextStyle(fontSize: 13),
            label: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            onPressed: () async {
              await GetPaidView.show(
                context,
                mode: contacts ? GetPaidMode.contacts : GetPaidMode.users,
              );
            },
            style: TextStyle(
              color: enabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 21, bottom: 3),
            child: Text(
              ' ¤',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: enabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  return Obx(() {
    return Column(
      children: [
        if (!c.verified.value) ...[],
        title(
          'От всех пользователей (кроме Ваших контактов и индивидуальных пользователей)',
          c.verified.value,
        ),
        const SizedBox(height: 6),
        field(
          label: 'label_fee_per_incoming_message'.l10n,
          state: c.allMessageCost,
          enabled: c.verified.value,
          contacts: false,
        ),
        field(
          label: 'label_fee_per_incoming_call_minute'.l10n,
          state: c.allCallCost,
          enabled: c.verified.value,
          contacts: false,
        ),
        const SizedBox(height: 12 * 2),
        title('От Ваших контактов', c.verified.value),
        const SizedBox(height: 6),
        field(
          label: 'label_fee_per_incoming_message'.l10n,
          state: c.contactMessageCost,
          enabled: c.verified.value,
          contacts: true,
        ),
        field(
          label: 'label_fee_per_incoming_call_minute'.l10n,
          state: c.contactCallCost,
          enabled: c.verified.value,
          contacts: true,
        ),
        const SizedBox(height: 12 * 2),
        title('От индивидуальных пользователей', c.verified.value),
        const SizedBox(height: 6),
        _dense(
          FieldButton(
            text: 'label_users_of'.l10n,
            onPressed: !c.verified.value || c.blacklist.isEmpty
                ? null
                : () => PaidListView.show(context),
            trailing: Text(
              '${c.blacklist.length}',
              style: style.fonts.bodyLarge.copyWith(
                fontSize: 15,
                color: !c.verified.value
                    ? style.colors.secondary
                    : c.blacklist.isEmpty
                        ? style.colors.onBackground
                        : style.colors.primary,
              ),
            ),
            style: TextStyle(
              color: !c.verified.value
                  ? style.colors.secondary
                  : c.blacklist.isEmpty
                      ? style.colors.onBackground
                      : style.colors.primary,
            ),
          ),
        ),
        Opacity(opacity: 0, child: _verification(context, c)),
      ],
    );
  });
}

Widget _donates(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  Widget title(String label, [bool enabled = true]) {
    return _dense(
      Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: style.systemMessageStyle.copyWith(
              // color: Theme.of(context).colorScheme.secondary,
              color:
                  enabled ? style.colors.onBackground : style.colors.secondary,
              fontSize: 15,

              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget field({
    required TextFieldState state,
    required String label,
    bool contacts = false,
    bool enabled = true,
  }) {
    return _padding(
      Stack(
        alignment: Alignment.centerLeft,
        children: [
          ReactiveTextField(
            state: state,
            prefixText: '    ',
            prefixStyle: const TextStyle(fontSize: 13),
            label: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            style: TextStyle(
              color: enabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 21, bottom: 3),
            child: Text(
              ' ¤',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color:
                    enabled ? style.colors.onBackground : style.colors.primary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  return Obx(() {
    return Column(
      children: [
        // title(
        //   'От всех пользователей (кроме Ваших контактов и индивидуальных пользователей)',
        //   c.verified.value,
        // ),
        field(
          label: 'Минимальная сумма подарка'.l10n,
          state: c.contactMessageCost,
          enabled: c.verified.value,
          contacts: true,
        ),
        _padding(
          ReactiveTextField(
            key: const Key('StatusField'),
            state: TextFieldState(text: '0'),
            formatters: [FilteringTextInputFormatter.digitsOnly],
            label: 'Максимальная длина сообщения'.l10n,
            filled: true,
            style: TextStyle(
              color: c.verified.value
                  ? style.colors.onBackground
                  : style.colors.primary,
            ),
          ),
        ),

        Opacity(opacity: 0, child: _verification(context, c)),
      ],
    );
  });
}

/// Returns the contents of a [ProfileTab.notifications] section.
Widget _notifications(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Obx(() {
    return _dense(
      Stack(
        alignment: Alignment.centerRight,
        children: [
          IgnorePointer(
            child: ReactiveTextField(
              state: TextFieldState(
                text: (c.myUser.value?.muted == null
                        ? 'label_enabled'
                        : 'label_disabled')
                    .l10n,
                editable: false,
              ),
              style: style.fonts.bodyMedium
                  .copyWith(color: style.colors.secondary),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Transform.scale(
                scale: 0.7,
                transformHitTests: false,
                child: Theme(
                  data: ThemeData(
                    platform: TargetPlatform.macOS,
                  ),
                  child: Switch.adaptive(
                    activeColor: style.colors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: c.myUser.value?.muted == null,
                    onChanged: c.isMuting.value ? null : c.toggleMute,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

/// Returns the contents of a [ProfileTab.download] section.
Widget _downloads(BuildContext context, MyProfileController c) {
  return _dense(
    const Column(
      children: [
        DownloadButton(
          asset: 'windows',
          width: 21.93,
          height: 22,
          title: 'Windows',
          link: 'messenger-windows.zip',
        ),
        SizedBox(height: 8),
        DownloadButton(
          asset: 'apple',
          width: 23,
          height: 29,
          title: 'macOS',
          link: 'messenger-macos.zip',
        ),
        SizedBox(height: 8),
        DownloadButton(
          asset: 'linux',
          width: 18.85,
          height: 22,
          title: 'Linux',
          link: 'messenger-linux.zip',
        ),
        SizedBox(height: 8),
        DownloadButton(
          asset: 'apple',
          width: 23,
          height: 29,
          title: 'iOS',
          link: 'messenger-ios.zip',
        ),
        SizedBox(height: 8),
        DownloadButton(
          asset: 'google',
          width: 20.33,
          height: 22.02,
          title: 'Android',
          link: 'messenger-android.apk',
        ),
      ],
    ),
  );
}

/// Returns the contents of a [ProfileTab.language] section.
Widget _language(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return _dense(
    FieldButton(
      key: const Key('ChangeLanguage'),
      onPressed: () => LanguageSelectionView.show(
        context,
        Get.find<AbstractSettingsRepository>(),
      ),
      text: 'label_language_entry'.l10nfmt({
        'code': L10n.chosen.value!.locale.countryCode,
        'name': L10n.chosen.value!.name,
      }),
      style: TextStyle(color: style.colors.primary),
    ),
  );
}

/// Returns the contents of a [ProfileTab.blacklist] section.
Widget _blockedUsers(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Column(
    children: [
      _dense(
        FieldButton(
          text: 'label_users'.l10n,
          trailing: Text(
            '${c.blacklist.length}',
            style: style.fonts.titleMedium.copyWith(
              color: c.blacklist.isEmpty
                  ? style.colors.onBackground
                  : style.colors.primary,
            ),
          ),
          onPressed:
              c.blacklist.isEmpty ? null : () => BlacklistView.show(context),
          style: style.fonts.titleMedium.copyWith(
            color: c.blacklist.isEmpty
                ? style.colors.onBackground
                : style.colors.primary,
          ),
        ),
      ),
    ],
  );
}

/// Returns the contents of a [ProfileTab.storage] section.
Widget _storage(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Paddings.dense(
    Column(
      children: [
        Obx(() {
          return SwitchField(
            text: 'label_load_images'.l10n,
            value: c.settings.value?.loadImages == true,
            onChanged: c.settings.value == null ? null : c.setLoadImages,
          );
        }),
        if (!PlatformUtils.isWeb) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 21.0),
              child: Text(
                'label_cache'.l10n,
                style: style.fonts.titleMediumSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final int size = CacheWorker.instance.info.value.size;
            const int max = CacheWorker.maxSize;

            return Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    LinearProgressIndicator(
                      value: size / max,
                      minHeight: 32,
                      color: style.colors.primary,
                      backgroundColor: style.colors.background,
                    ),
                    Text(
                      'label_gb_slash_gb'.l10nfmt({
                        'a': (size / GB).toPrecision(2),
                        'b': (max ~/ GB).toDouble().toPrecision(2),
                      }),
                      style: style.fonts.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FieldButton(
                  onPressed: c.clearCache,
                  text: 'btn_clear_cache'.l10n,
                  style: style.fonts.titleMediumPrimary,
                ),
              ],
            );
          }),
        ],
      ],
    ),
  );
}

Widget _devices(BuildContext context, MyProfileController c) {
  final style = Theme.of(context).style;

  return Paddings.dense(
    Column(
      children: [
        FieldButton(
          text: 'btn_scan_qr_code'.l10n,
          onPressed: () {
            QrCodeView.show(
              context,
              title: 'btn_scan_qr_code'.l10n,
              scanning: false,
              path: 'label_show_qr_code_to_sign_in3'.l10n,
            );
          },
        ),
        const SizedBox(height: 16),
        FieldButton(
          text: 'btn_show_qr_code'.l10n,
          onPressed: () {
            QrCodeView.show(
              context,
              title: 'btn_show_qr_code'.l10n,
              scanning: true,
              path: 'label_show_qr_code_to_sign_in3'.l10n,
            );
          },
        ),
      ],
    ),
  );
}

/// Opens a confirmation popup deleting the provided [email] from the
/// [MyUser.emails].
Future<void> _deleteEmail(
  MyProfileController c,
  BuildContext context,
  UserEmail email,
) async {
  final style = Theme.of(context).style;

  final bool? result = await MessagePopup.alert(
    'label_delete_email'.l10n,
    description: [
      TextSpan(text: 'alert_email_will_be_deleted1'.l10n),
      TextSpan(
        text: email.val,
        style: TextStyle(color: style.colors.onBackground),
      ),
      TextSpan(text: 'alert_email_will_be_deleted2'.l10n),
    ],
  );

  if (result == true) {
    await c.deleteEmail(email);
  }
}

/// Opens a confirmation popup deleting the provided [phone] from the
/// [MyUser.phones].
Future<void> _deletePhone(
  MyProfileController c,
  BuildContext context,
  UserPhone phone,
) async {
  final style = Theme.of(context).style;

  final bool? result = await MessagePopup.alert(
    'label_delete_phone_number'.l10n,
    description: [
      TextSpan(text: 'alert_phone_will_be_deleted1'.l10n),
      TextSpan(
        text: phone.val,
        style: TextStyle(color: style.colors.onBackground),
      ),
      TextSpan(text: 'alert_phone_will_be_deleted2'.l10n),
    ],
  );

  if (result == true) {
    await c.deletePhone(phone);
  }
}

/// Opens a confirmation popup deleting the [MyUser]'s account.
Future<void> _deleteAccount(MyProfileController c, BuildContext context) async {
  final style = Theme.of(context).style;

  final bool? result = await MessagePopup.alert(
    'label_delete_account'.l10n,
    description: [
      TextSpan(text: 'alert_account_will_be_deleted1'.l10n),
      TextSpan(
        text: c.myUser.value?.name?.val ??
            c.myUser.value?.login?.val ??
            c.myUser.value?.num.val ??
            'dot'.l10n * 3,
        style: TextStyle(color: style.colors.onBackground),
      ),
      TextSpan(text: 'alert_account_will_be_deleted2'.l10n),
    ],
  );

  if (result == true) {
    await c.deleteAccount();
  }
}
