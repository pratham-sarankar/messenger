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

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/ui/page/home/widget/avatar.dart';
import 'package:messenger/ui/page/home/widget/contact_tile.dart';

import '/l10n/l10n.dart';
import '/ui/page/home/page/my_profile/widget/copyable.dart';
import '/ui/page/home/widget/sharable.dart';
import '/ui/widget/modal_popup.dart';
import '/ui/widget/outlined_rounded_button.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import '/util/platform_utils.dart';
import 'controller.dart';

/// ...
///
/// Intended to be displayed with the [show] method.
class AccountsView extends StatelessWidget {
  const AccountsView({Key? key}) : super(key: key);

  /// Displays an [AccountsView] wrapped in a [ModalPopup].
  static Future<T?> show<T>(BuildContext context) {
    return ModalPopup.show(
      context: context,
      // desktopPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      // desktopConstraints: const BoxConstraints(
      //   maxWidth: double.infinity,
      //   maxHeight: double.infinity,
      // ),
      // desktopConstraints: const BoxConstraints(maxWidth: 400),
      // modalConstraints: const BoxConstraints(maxWidth: 520),
      mobilePadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      mobileConstraints: const BoxConstraints(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
      ),
      // color: const Color.fromARGB(255, 233, 235, 237),
      child: const AccountsView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final TextStyle? thin =
        theme.textTheme.bodyText1?.copyWith(color: Colors.black);

    return GetBuilder(
      key: const Key('AccountsView'),
      init: AccountsController(Get.find()),
      builder: (AccountsController c) {
        return Obx(() {
          List<Widget> children;

          switch (c.stage.value) {
            case AccountsViewStage.login:
              children = [
                Center(
                  child: Text(
                    'Login'.l10n,
                    style: thin?.copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 50),
                ReactiveTextField(
                  key: const Key('LoginField'),
                  state: c.login,
                  label: 'label_login'.l10n,
                  style: thin,
                  treatErrorAsStatus: false,
                ),
                const SizedBox(height: 12),
                ReactiveTextField(
                  key: const Key('PasswordField'),
                  state: c.password,
                  label: 'label_password'.l10n,
                  obscure: c.obscurePassword.value,
                  style: thin,
                  onSuffixPressed: c.obscurePassword.toggle,
                  treatErrorAsStatus: false,
                  trailing: SvgLoader.asset(
                    'assets/icons/visible_${c.obscurePassword.value ? 'off' : 'on'}.svg',
                    width: 17.07,
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedRoundedButton(
                        key: const Key('BackButton'),
                        maxWidth: null,
                        title: Text('btn_back'.l10n, style: thin),
                        onPressed: () => c.stage.value = AccountsViewStage.add,
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedRoundedButton(
                        key: const Key('LoginButton'),
                        maxWidth: null,
                        title: Text(
                          'Login'.l10n,
                          style: thin?.copyWith(color: Colors.white),
                        ),
                        onPressed: () {},
                        color: const Color(0xFF63B4FF),
                      ),
                    ),
                  ],
                ),
              ];
              break;

            case AccountsViewStage.add:
              children = [
                Center(
                  child: Text(
                    'Add account'.l10n,
                    style: thin?.copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: OutlinedRoundedButton(
                    title: Text(
                      'New account'.l10n,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: Navigator.of(context).pop,
                    color: const Color(0xFF63B4FF),
                    maxWidth: null,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: OutlinedRoundedButton(
                    title: Text('Login'.l10n),
                    onPressed: () => c.stage.value = AccountsViewStage.login,
                    color: const Color(0xFFEEEEEE),
                    maxWidth: null,
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: OutlinedRoundedButton(
                    key: const Key('CloseButton'),
                    title: Text('btn_back'.l10n),
                    onPressed: () => c.stage.value = null,
                    color: const Color(0xFFEEEEEE),
                    maxWidth: null,
                  ),
                ),
              ];
              break;

            default:
              children = [
                Center(
                  child: Text(
                    'Your accounts'.l10n,
                    style: thin?.copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 25),
                ContactTile(
                  myUser: c.myUser.value,
                  // darken: 0,
                  // border:
                  // Border.all(width: 0.5, color: const Color(0xFF888888)),
                  trailing: const [
                    Icon(Icons.check_circle_outline, color: Color(0xFF63B4FF))
                  ],
                  subtitle: const [
                    SizedBox(height: 5),
                    Text(
                      'Online',
                      style: TextStyle(color: Color(0xFF888888)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedRoundedButton(
                  maxWidth: null,
                  title: Text(
                    'Add account'.l10n,
                    // style: thin?.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () => c.stage.value = AccountsViewStage.add,
                  // color: const Color(0xFF63B4FF),
                  color: Colors.white.darken(0.05),
                ),
                // const SizedBox(height: 25),
                // Row(
                //   children: [
                //     Expanded(
                //       child: OutlinedRoundedButton(
                //         key: const Key('CloseButton'),
                //         maxWidth: null,
                //         title: Text('btn_close'.l10n, style: thin),
                //         onPressed: Navigator.of(context).pop,
                //         color: const Color(0xFFEEEEEE),
                //       ),
                //     ),
                //     // const SizedBox(width: 10),
                //     // Expanded(
                //     //   child: OutlinedRoundedButton(
                //     //     key: const Key('SetPasswordButton'),
                //     //     maxWidth: null,
                //     //     title: Text(
                //     //       'Add account'.l10n,
                //     //       style: thin?.copyWith(color: Colors.white),
                //     //       maxLines: 1,
                //     //       overflow: TextOverflow.ellipsis,
                //     //     ),
                //     //     onPressed: () => c.stage.value = AccountsViewStage.add,
                //     //     color: const Color(0xFF63B4FF),
                //     //   ),
                //     // ),
                //   ],
                // ),
              ];
              break;
          }

          return AnimatedSizeAndFade(
            fadeDuration: const Duration(milliseconds: 250),
            sizeDuration: const Duration(milliseconds: 250),
            child: ListView(
              key: Key('${c.stage.value?.name.capitalizeFirst}Stage'),
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                const SizedBox(height: 12),
                ...children,
                const SizedBox(height: 12),
              ],
            ),
          );
        });
      },
    );
  }
}