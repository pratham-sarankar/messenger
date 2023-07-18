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

import '/themes.dart';
import '/ui/widget/outlined_rounded_button.dart';

/// Styled [OutlinedRoundedButton] used for [Routes.style] pages.
class StyleCard extends StatelessWidget {
  const StyleCard({
    super.key,
    this.title,
    this.icon,
    this.onPressed,
    this.inverted = false,
  });

  /// Title of this [StyleCard].
  final String? title;

  /// Icon of this [StyleCard].
  final IconData? icon;

  /// Indicator whether this [StyleCard] should have its colors
  /// inverted.
  final bool inverted;

  /// Callback, called when this [StyleCard] is pressed.
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final fonts = Theme.of(context).fonts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: OutlinedRoundedButton(
        color: inverted ? const Color(0xFF1F3C5D) : const Color(0xFFFFFFFF),
        onPressed: onPressed,
        title: Row(
          children: [
            Icon(
              icon,
              color:
                  inverted ? const Color(0xFFFFFFFF) : const Color(0xFF1F3C5D),
            ),
            const SizedBox(width: 7),
            if (title != null)
              Text(
                title!,
                style: fonts.headlineLarge!.copyWith(
                  color: inverted
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF1F3C5D),
                ),
              ),
          ],
        ),
      ),
    );
  }
}