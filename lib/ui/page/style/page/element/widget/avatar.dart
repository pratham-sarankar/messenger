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

// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/page/home/widget/avatar.dart';
import '/ui/widget/progress_indicator.dart';
import '/ui/widget/widget_button.dart';
import '/l10n/l10n.dart';
import '/themes.dart';

/// View of the avatar widgets.
class AvatarView extends StatelessWidget {
  const AvatarView({super.key, required this.isDarkMode});

  /// Indicator whether this page is in dark mode.
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AnimatedCircleWidget(isDarkMode: isDarkMode),
        const SizedBox(height: 16),
        _AvatarSizesWidget(isDarkMode: isDarkMode),
      ],
    );
  }
}

/// Avatar widget which used in [ChatInfoView], [MyProfileView].
class _AnimatedCircleWidget extends StatelessWidget {
  const _AnimatedCircleWidget({super.key, required this.isDarkMode});

  /// Indicator whether this page is in dark mode.
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF142839) : style.colors.onPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      height: 260,
      width: 250,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: Text(
                'AnimatedCircleAvatar',
                style: style.fonts.headlineLarge.copyWith(
                  color: isDarkMode
                      ? style.colors.onPrimary
                      : style.colors.onBackground,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Tooltip(
              message: 'Radius: 100 \nUsed in: ChatInfoView, MyProfileView',
              child: _AnimatedCircleAvatar(
                avatar: AvatarWidget(radius: 100, title: 'John Doe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// View of all colors of [AvatarWidget].
class _AvatarColorsWidget extends StatelessWidget {
  const _AvatarColorsWidget({super.key, required this.isDarkMode});

  /// Indicator whether this page is in dark mode.
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF142839) : style.colors.onPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      height: 260,
      width: 505,
      child: Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        child: Column(
          children: [
            Center(
              child: Text(
                'Avatar colors',
                style: style.fonts.headlineLarge.copyWith(
                  color: isDarkMode
                      ? style.colors.onPrimary
                      : style.colors.onBackground,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 199,
              width: 470,
              child: Flexible(
                child: GridView.count(
                  crossAxisCount: style.colors.userColors.length ~/ 2,
                  children: List.generate(
                    style.colors.userColors.length,
                    (i) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AvatarWidget(
                        radius: 100,
                        title: 'John Doe',
                        color: i,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// View of all sizes of [AvatarWidget].
class _AvatarSizesWidget extends StatelessWidget {
  const _AvatarSizesWidget({super.key, required this.isDarkMode});

  /// Indicator whether this page is in dark mode.
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF142839) : style.colors.onPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      height: 130,
      width: 285,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Center(
              child: Text(
                'AvatarWidget',
                style: style.fonts.headlineLarge.copyWith(
                  color: isDarkMode
                      ? style.colors.onPrimary
                      : style.colors.onBackground,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StyledAvatar(
                    message: 'Radius: 32 \nUsed in: CallTitle', radius: 32),
                _StyledAvatar(
                  message: 'Radius: 30 \nUsed in: mobileCall, ChatTile',
                  radius: 30,
                ),
                _StyledAvatar(
                    message:
                        'Radius: 17 \nUsed in: ChatView, ChatInfoView, ChatForward, ChatItem, UserView, MenuTabView, ContactTile',
                    radius: 17),
                _StyledAvatar(
                    message: 'Radius: 15 \nUsed in: HomeView', radius: 15),
                _StyledAvatar(
                  message:
                      'Radius: 10 \nUsed in: ChatForward, ChatItem, RecentChat',
                  radius: 10,
                ),
                _StyledAvatar(
                    message: 'Radius: 8 \nUsed in: desktopCall', radius: 8),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// [AvatarWidget] with [Tooltip] and given [radius].
class _StyledAvatar extends StatelessWidget {
  const _StyledAvatar({super.key, required this.message, required this.radius});

  /// [Tooltip] message of this [_StyledAvatar].
  final String message;

  /// [AvatarWidget]'s radius.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: AvatarWidget(
          title: 'John Doe',
          radius: radius,
        ),
      ),
    );
  }
}

/// TODO: Replace with AnimatedCircleAvatar after merge #427
class _AnimatedCircleAvatar extends StatelessWidget {
  const _AnimatedCircleAvatar({
    super.key,
    this.avatar,
    this.onPressed,
    this.onPressedAdditional,
    this.isLoading = false,
    this.isVisible = true,
  });

  /// Indicator whether this widget is currently loading.
  final bool isLoading;

  /// Indicator whether the additional label should be shown.
  final bool isVisible;

  /// [Widget] that is displayed within the circle.
  final Widget? avatar;

  /// Callback, called when label was pressed.
  final void Function()? onPressed;

  /// Callback, called when additional label was pressed.
  final void Function()? onPressedAdditional;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (avatar != null) avatar!,
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: 200.milliseconds,
                child: isLoading
                    ? Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: style.colors.onBackgroundOpacity13,
                        ),
                        child: const Center(child: CustomProgressIndicator()),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WidgetButton(
              key: const Key('UploadAvatar'),
              onPressed: onPressed,
              child: Text(
                'btn_upload'.l10n,
                style: style.fonts.labelSmallPrimary,
              ),
            ),
            if (isVisible) ...[
              Text(
                'space_or_space'.l10n,
                style: style.fonts.labelSmall.copyWith(
                  color: style.colors.onBackground,
                ),
              ),
              WidgetButton(
                key: const Key('DeleteAvatar'),
                onPressed: onPressedAdditional,
                child: Text(
                  'btn_delete'.l10n.toLowerCase(),
                  style: style.fonts.labelSmallOnPrimary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}