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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '/config.dart';
import '/l10n/l10n.dart';
import '/routes.dart';
import '/themes.dart';
import '/ui/widget/modal_popup.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import '/util/message_popup.dart';
import '/ui/page/home/page/my_profile/link_details/view.dart';
import 'controller.dart';

/// View for changing [MyUser.chatDirectLink] and [MyUser.muted].
///
/// Intended to be displayed with the [show] method.
class BalanceMoreView extends StatelessWidget {
  const BalanceMoreView({super.key});

  /// Displays a [ChatsMoreView] wrapped in a [ModalPopup].
  static Future<T?> show<T>(BuildContext context) {
    return ModalPopup.show(context: context, child: const BalanceMoreView());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      key: const Key('BalanceMoreView'),
      init: BalanceMoreController(Get.find()),
      builder: (BalanceMoreController c) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalPopupHeader(
              header: Center(
                child: Text(
                  'label_display_balance'.l10n,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            Flexible(
              child: ListView(
                padding: ModalPopup.padding(context),
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 8),
                  _balance(context, c),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Returns a styled as a header [Container] with the provided [text].
  Widget _header(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            text,
            style: Theme.of(context)
                .extension<Style>()!
                .systemMessageStyle
                .copyWith(color: Colors.black, fontSize: 18),
          ),
        ),
      ),
    );
  }

  /// Returns a [Switch] toggling [MyUser.muted].
  Widget _balance(BuildContext context, BalanceMoreController c) {
    return Obx(() {
      return Stack(
        alignment: Alignment.centerRight,
        children: [
          IgnorePointer(
            child: ReactiveTextField(
              state: TextFieldState(
                text: (c.displayFunds
                        ? 'label_balance_enabled'
                        : 'label_balance_disabled')
                    .l10n,
                editable: false,
              ),
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
                    activeColor: Theme.of(context).colorScheme.secondary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: c.displayFunds,
                    onChanged: c.setDisplayFunds,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
