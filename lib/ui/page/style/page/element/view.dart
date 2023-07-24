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

import '/ui/page/style/widget/header.dart';
import 'widget/avatar.dart';
import 'widget/button.dart';
import 'widget/navigation.dart';
import 'widget/containment.dart';
import 'widget/switcher.dart';
import 'widget/system_messages.dart';
import 'widget/text_field.dart';

/// Elements view of the [Routes.style] page.
class ElementsView extends StatelessWidget {
  const ElementsView(
    this.isDarkMode,
    this.compact, {
    super.key,
  });

  final bool isDarkMode;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Padding(
                padding: EdgeInsets.all(compact ? 0 : 20),
                child: Column(
                  children: [
                    const Header(label: 'Elements'),
                    const SmallHeader(label: 'Avatars'),
                    AvatarView(isDarkMode: isDarkMode),
                    const Divider(),
                    const SmallHeader(label: 'Text fields'),
                    TextFieldWidget(isDarkMode: isDarkMode),
                    const Divider(),
                    const SmallHeader(label: 'Buttons'),
                    ButtonsWidget(isDarkMode: isDarkMode),
                    const Divider(),
                    const SmallHeader(label: 'Switchers'),
                    SwitcherWidget(isDarkMode: isDarkMode),
                    const Divider(),
                    const SmallHeader(label: 'Containment'),
                    const ContainmentWidget(),
                    const Divider(),
                    const SmallHeader(label: 'System messages'),
                    SystemMessagesWidget(isDarkMode),
                    const Divider(),
                    const SmallHeader(label: 'Navigation'),
                    const NavigationWidget(),
                    const Divider(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
