// Copyright © 2022 IT ENGINEERING MANAGEMENT INC, <https://github.com/team113>
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

import 'dart:io';
import 'dart:ui';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:get/get.dart';
import 'package:messenger/domain/model/user.dart';
import 'package:messenger/domain/repository/contact.dart';
import 'package:messenger/ui/page/call/widget/conditional_backdrop.dart';
import 'package:messenger/ui/page/call/widget/round_button.dart';
import 'package:messenger/ui/page/home/page/chat/widget/my_dismissible.dart';
import 'package:messenger/ui/page/home/widget/contact_tile.dart';
import 'package:messenger/ui/widget/context_menu/region.dart';
import 'package:messenger/ui/widget/outlined_rounded_button.dart';
import 'package:messenger/ui/widget/widget_button.dart';

import '/api/backend/schema.dart' show ChatCallFinishReason;
import '/config.dart';
import '/domain/model/attachment.dart';
import '/domain/model/chat.dart';
import '/domain/model/chat_call.dart';
import '/domain/model/chat_item.dart';
import '/domain/model/chat_item_quote.dart';
import '/domain/model/sending_status.dart';
import '/domain/repository/chat.dart';
import '/domain/repository/user.dart';
import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/controller.dart';
import '/ui/page/home/page/chat/widget/chat_item.dart';
import '/ui/page/home/page/chat/forward/controller.dart';
import '/ui/page/home/page/chat/widget/animated_fab.dart';
import '/ui/page/home/widget/avatar.dart';
import '/ui/widget/animations.dart';
import '/ui/widget/modal_popup.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import '/util/platform_utils.dart';
import 'controller.dart';

/// View for forwarding the provided [quotes] into the selected [Chat]s.
///
/// Intended to be displayed with the [show] method.
class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({Key? key}) : super(key: key);

  /// Displays a [ChatForwardView] wrapped in a [ModalPopup].
  static Future<T?> show<T>(BuildContext context, {UserEmail? email}) {
    return ModalPopup.show(
      context: context,
      desktopConstraints: const BoxConstraints(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
      ),
      modalConstraints: const BoxConstraints(maxWidth: 380),
      mobilePadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      mobileConstraints: const BoxConstraints(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
      ),
      child: const ChangePasswordView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? thin =
        Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.black);

    return GetBuilder(
      init: ChangePasswordController(Get.find()),
      builder: (ChangePasswordController c) {
        return Obx(() {
          final List<Widget> children;

          switch (c.stage.value) {
            case ChangePasswordFlowStage.set:
            case ChangePasswordFlowStage.changed:
              children = [
                Flexible(
                  child: Padding(
                    padding: ModalPopup.padding(context),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            c.stage.value == ChangePasswordFlowStage.set
                                ? 'label_password_set'.l10n
                                : 'label_password_changed'.l10n,
                            style: thin?.copyWith(
                              fontSize: 15,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        OutlinedRoundedButton(
                          key: const Key('Close'),
                          maxWidth: null,
                          title: Text(
                            'btn_close'.l10n,
                            style: thin?.copyWith(color: Colors.white),
                          ),
                          onPressed: Navigator.of(context).pop,
                          color: const Color(0xFF63B4FF),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
              break;

            default:
              children = [
                Flexible(
                  child: Padding(
                    padding: ModalPopup.padding(context),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Obx(() {
                          if (c.myUser.value?.hasPassword != true) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 25),
                              child: Text(
                                'label_password_not_set_info'.l10n,
                                style: thin?.copyWith(
                                  fontSize: 15,
                                  color: const Color(0xFF888888),
                                ),
                              ),
                            );
                          }

                          return const SizedBox();
                        }),
                        Obx(() {
                          if (c.myUser.value?.hasPassword == true) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ReactiveTextField(
                                state: c.oldPassword,
                                label: 'label_current_password'.l10n,
                                obscure: c.obscurePassword.value,
                                onSuffixPressed: c.obscurePassword.toggle,
                                treatErrorAsStatus: false,
                                trailing: SvgLoader.asset(
                                  'assets/icons/visible_${c.obscurePassword.value ? 'off' : 'on'}.svg',
                                  width: 17.07,
                                ),
                              ),
                            );
                          }

                          return const SizedBox();
                        }),
                        ReactiveTextField(
                          state: c.newPassword,
                          label: 'label_new_password'.l10n,
                          obscure: c.obscureNewPassword.value,
                          onSuffixPressed: c.obscureNewPassword.toggle,
                          treatErrorAsStatus: false,
                          trailing: SvgLoader.asset(
                            'assets/icons/visible_${c.obscureNewPassword.value ? 'off' : 'on'}.svg',
                            width: 17.07,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ReactiveTextField(
                          state: c.repeatPassword,
                          label: 'label_repeat_password'.l10n,
                          obscure: c.obscureRepeatPassword.value,
                          onSuffixPressed: c.obscureRepeatPassword.toggle,
                          treatErrorAsStatus: false,
                          trailing: SvgLoader.asset(
                            'assets/icons/visible_${c.obscureRepeatPassword.value ? 'off' : 'on'}.svg',
                            width: 17.07,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Obx(() {
                          final bool enabled;
                          if (c.myUser.value?.hasPassword == true) {
                            enabled = !c.oldPassword.isEmpty.value &&
                                !c.newPassword.isEmpty.value &&
                                !c.repeatPassword.isEmpty.value;
                          } else {
                            enabled = !c.newPassword.isEmpty.value &&
                                !c.repeatPassword.isEmpty.value;
                          }

                          return OutlinedRoundedButton(
                            key: const Key('Proceed'),
                            maxWidth: null,
                            title: Text(
                              'btn_proceed'.l10n,
                              style: thin?.copyWith(
                                color: enabled ? Colors.white : Colors.black,
                              ),
                            ),
                            onPressed: enabled ? c.changePassword : null,
                            color: const Color(0xFF63B4FF),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ];
              break;
          }

          return AnimatedSizeAndFade(
            fadeDuration: const Duration(milliseconds: 250),
            sizeDuration: const Duration(milliseconds: 250),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const SizedBox(height: 16 - 12),
                ModalPopupHeader(
                  header: Center(
                    child: Text(
                      c.myUser.value?.hasPassword == true &&
                              c.stage.value != ChangePasswordFlowStage.set
                          ? 'Change password'.l10n
                          : 'Set password'.l10n,
                      style: thin?.copyWith(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 25 - 12),
                ...children,
                const SizedBox(height: 16),
              ],
            ),
          );
        });
      },
    );
  }
}