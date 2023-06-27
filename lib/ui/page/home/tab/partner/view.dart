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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/themes.dart';
import 'package:messenger/ui/page/home/widget/app_bar.dart';
import 'package:messenger/ui/page/home/widget/balance_provider.dart';
import 'package:messenger/ui/page/home/widget/safe_scrollbar.dart';
import 'package:messenger/ui/page/home/widget/transaction.dart';
import 'package:messenger/ui/widget/svg/svg.dart';
import 'package:messenger/ui/widget/widget_button.dart';

import 'controller.dart';

class PartnerTabView extends StatelessWidget {
  const PartnerTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return GetBuilder(
      init: PartnerTabController(Get.find()),
      builder: (PartnerTabController c) {
        return Scaffold(
          // extendBodyBehindAppBar: true,
          appBar: CustomAppBar(
            title: Text('Balance: \$${c.balance.value / 100}'),
            leading: [
              Obx(() {
                final Widget child;

                if (c.withdrawing.value) {
                  child = SvgImage.asset(
                    'assets/icons/info.svg',
                    width: 20,
                    height: 20,
                  );
                } else {
                  child = SvgImage.asset(
                    key: const Key('Search'),
                    'assets/icons/search.svg',
                    width: 17.77,
                  );
                }

                return WidgetButton(
                  onPressed: c.hintDismissed.toggle,
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, right: 12),
                    height: double.infinity,
                    child: child,
                  ),
                );
              }),
            ],
            actions: [
              Obx(() {
                final Widget child;

                if (c.withdrawing.value) {
                  child = SvgImage.asset(
                    key: const Key('CloseSearch'),
                    'assets/icons/transactions.svg',
                    width: 19,
                    height: 19.42,
                  );
                } else {
                  child = Transform.translate(
                    offset: const Offset(0, 0),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    // child: SvgImage.asset(
                    //   'assets/icons/transactions.svg',
                    //   width: 19,
                    //   height: 19.42,
                    // ),
                  );
                }

                return WidgetButton(
                  onPressed: c.withdrawing.toggle,
                  child: Container(
                    padding: const EdgeInsets.only(left: 12, right: 20),
                    height: double.infinity,
                    child: SizedBox(width: 20.28, child: Center(child: child)),
                  ),
                );
              }),
            ],
          ),
          body: Obx(() {
            if (c.withdrawing.value) {
              Widget button({
                required String title,
                required IconData icon,
              }) {
                return BalanceProviderWidget(
                  title: title,
                  leading: [Icon(icon)],
                  onTap: () {},
                );
              }

              return SafeScrollbar(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    button(title: 'SWIFT', icon: Icons.account_balance),
                    button(title: 'SEPA', icon: Icons.account_balance),
                    button(title: 'PayPal', icon: Icons.paypal),
                  ],
                ),
              );
            }

            return SafeScrollbar(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  ...c.transactions.map((e) {
                    return TransactionWidget(e);
                  }).toList(),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}