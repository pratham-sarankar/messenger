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

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/ui/page/home/page/chat/widget/chat_item.dart';
import 'package:messenger/ui/page/home/page/my_profile/widget/download_button.dart';
import 'package:messenger/ui/page/home/widget/field_button.dart';
import 'package:messenger/ui/widget/outlined_rounded_button.dart';
import 'package:messenger/util/platform_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/widget/modal_popup.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import '/ui/widget/widget_button.dart';
import 'controller.dart';
import 'widget/primary_button.dart';

/// View for logging in or recovering access on.
///
/// Intended to be displayed with the [show] method.
class LoginView extends StatelessWidget {
  const LoginView({
    super.key,
    this.stage = LoginViewStage.signUp,
  });

  final LoginViewStage stage;

  /// Displays a [LoginView] wrapped in a [ModalPopup].
  static Future<T?> show<T>(
    BuildContext context, {
    LoginViewStage stage = LoginViewStage.signUp,
  }) {
    return ModalPopup.show(
      context: context,
      child: LoginView(stage: stage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (style, fonts) = Theme.of(context).styles;

    return GetBuilder(
      key: const Key('LoginView'),
      init: LoginController(Get.find(), stage: stage),
      builder: (LoginController c) {
        return Obx(() {
          final Widget header;
          final List<Widget> children;

          switch (c.stage.value) {
            case LoginViewStage.noPassword:
              header = ModalPopupHeader(
                onBack: () => c.stage.value = LoginViewStage.signIn,
                text: 'Sign in without password'.l10n,
              );

              children = [
                // const SizedBox(height: 12),
                Text(
                  'label_recover_account_description'.l10n,
                  style: fonts.titleLarge!.copyWith(
                    color: style.colors.secondary,
                  ),
                ),
                const SizedBox(height: 25),
                ReactiveTextField(
                  key: const Key('RecoveryField'),
                  state: c.login,
                  label: 'E-mail or phone number'.l10n,
                ),
                const SizedBox(height: 25),
                PrimaryButton(
                  key: const Key('Proceed'),
                  title: 'btn_proceed'.l10n,
                  onPressed:
                      c.login.isEmpty.value ? null : c.signInWithoutPassword,
                ),
                // const SizedBox(height: 16),
              ];
              break;

            case LoginViewStage.noPasswordCode:
              header = ModalPopupHeader(
                onBack: () => c.stage.value = LoginViewStage.signIn,
                text: 'Sign in without password'.l10n,
              );

              children = [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'label_sign_in_code_sent1'.l10n,
                        style: fonts.titleLarge!.copyWith(
                          color: style.colors.secondary,
                        ),
                      ),
                      TextSpan(
                        text: c.login.text,
                        style: fonts.titleLarge!.copyWith(
                          color: style.colors.onBackground,
                        ),
                      ),
                      TextSpan(
                        text: 'label_sign_in_code_sent2'.l10n,
                        style: fonts.titleLarge!.copyWith(
                          color: style.colors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                ReactiveTextField(
                  key: const Key('RecoveryCodeField'),
                  state: c.recoveryCode,
                  label: 'label_confirmation_code'.l10n,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 25),
                PrimaryButton(
                  key: const Key('Proceed'),
                  title: 'btn_proceed'.l10n,
                  onPressed: c.recoveryCode.isEmpty.value
                      ? null
                      : c.recoveryCode.submit,
                ),
                // const SizedBox(height: 16),
              ];
              break;

            case LoginViewStage.recovery:
              header = ModalPopupHeader(
                onBack: () => c.stage.value = LoginViewStage.signIn,
                text: 'label_recover_account'.l10n,
              );

              children = [
                const SizedBox(height: 12),
                Text(
                  'label_recover_account_description'.l10n,
                  style: fonts.titleLarge!.copyWith(
                    color: style.colors.secondary,
                  ),
                ),
                const SizedBox(height: 25),
                ReactiveTextField(
                  key: const Key('RecoveryField'),
                  state: c.recovery,
                  label: 'E-mail or phone number'.l10n,
                ),
                const SizedBox(height: 25),
                PrimaryButton(
                  key: const Key('Proceed'),
                  title: 'btn_proceed'.l10n,
                  onPressed:
                      c.recovery.isEmpty.value ? null : c.recovery.submit,
                ),
                // const SizedBox(height: 16),
              ];
              break;

            case LoginViewStage.recoveryCode:
              header = ModalPopupHeader(
                onBack: () => c.stage.value = LoginViewStage.signIn,
                text: 'label_recover_account'.l10n,
              );

              children = [
                Text(
                  'label_recovery_code_sent'.l10n,
                  style: fonts.titleLarge!.copyWith(
                    color: style.colors.secondary,
                  ),
                ),
                const SizedBox(height: 25),
                ReactiveTextField(
                  key: const Key('RecoveryCodeField'),
                  state: c.recoveryCode,
                  label: 'label_recovery_code'.l10n,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 25),
                PrimaryButton(
                  key: const Key('Proceed'),
                  title: 'btn_proceed'.l10n,
                  onPressed: c.recoveryCode.isEmpty.value
                      ? null
                      : c.recoveryCode.submit,
                ),
                // const SizedBox(height: 16),
              ];
              break;

            case LoginViewStage.recoveryPassword:
              header = ModalPopupHeader(
                onBack: () => c.stage.value = LoginViewStage.signIn,
                text: 'label_recover_account'.l10n,
              );

              children = [
                Text(
                  'label_recovery_enter_new_password'.l10n,
                  style: fonts.titleLarge!.copyWith(
                    color: style.colors.secondary,
                  ),
                ),
                const SizedBox(height: 25),
                ReactiveTextField(
                  key: const Key('PasswordField'),
                  state: c.newPassword,
                  label: 'label_new_password'.l10n,
                  obscure: c.obscureNewPassword.value,
                  onSuffixPressed: c.obscureNewPassword.toggle,
                  treatErrorAsStatus: false,
                  trailing: SvgImage.asset(
                    'assets/icons/visible_${c.obscureNewPassword.value ? 'off' : 'on'}.svg',
                    width: 17.07,
                  ),
                ),
                const SizedBox(height: 16),
                ReactiveTextField(
                  key: const Key('RepeatPasswordField'),
                  state: c.repeatPassword,
                  label: 'label_repeat_password'.l10n,
                  obscure: c.obscureRepeatPassword.value,
                  onSuffixPressed: c.obscureRepeatPassword.toggle,
                  treatErrorAsStatus: false,
                  trailing: SvgImage.asset(
                    'assets/icons/visible_${c.obscureRepeatPassword.value ? 'off' : 'on'}.svg',
                    width: 17.07,
                  ),
                ),
                const SizedBox(height: 25),
                PrimaryButton(
                  key: const Key('Proceed'),
                  title: 'btn_proceed'.l10n,
                  onPressed: c.newPassword.isEmpty.value ||
                          c.repeatPassword.isEmpty.value
                      ? null
                      : c.resetUserPassword,
                ),
                // const SizedBox(height: 16),
              ];
              break;

            case LoginViewStage.code:
              header = ModalPopupHeader(
                onBack: () => c.stage.value = LoginViewStage.signUp,
                text: 'Sign up'.l10n,
              );

              children = [
                // Text(
                //   'label_recovery_code_sent'.l10n,
                //   style: fonts.labelLarge!.copyWith(
                //     color: style.colors.secondary,
                //   ),
                // ),
                Text.rich(
                  'label_sign_up_code_email_sent'.l10nfmt({
                    'text': c.email.text,
                  }).parseLinks([], context),
                  style: fonts.titleLarge,
                ),
                const SizedBox(height: 25),
                ReactiveTextField(
                  key: const Key('EmailCodeField'),
                  state: c.emailCode,
                  label: 'label_confirmation_code'.l10n,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 25),
                PrimaryButton(
                  key: const Key('Proceed'),
                  title: 'btn_proceed'.l10n,
                  onPressed:
                      c.emailCode.isEmpty.value ? null : c.emailCode.submit,
                ),
                // const SizedBox(height: 16),
              ];
              break;

            case LoginViewStage.signUpWithPhone:
              header = ModalPopupHeader(
                text: 'label_sign_up'.l10n,
                onBack: () => c.stage.value = LoginViewStage.signUp,
              );

              children = [
                ReactiveTextField(
                  state: c.email,
                  label: 'label_phone_number'.l10n,
                  style: fonts.bodyMedium,
                  treatErrorAsStatus: false,
                ),
                const SizedBox(height: 25),
                Center(
                  child: Obx(() {
                    final bool enabled =
                        !c.email.isEmpty.value && c.email.error.value == null;

                    return OutlinedRoundedButton(
                      title: Text(
                        'btn_proceed'.l10n,
                        style: fonts.titleLarge!.copyWith(
                          color: enabled
                              ? style.colors.onPrimary
                              : fonts.titleLarge!.color,
                        ),
                      ),
                      onPressed: enabled ? c.email.submit : null,
                      color: style.colors.primary,
                      maxWidth: double.infinity,
                    );
                  }),
                ),
                const SizedBox(height: 25 / 2),
              ];
              break;

            case LoginViewStage.signUpWithEmail:
              header = ModalPopupHeader(
                text: 'label_sign_up'.l10n,
                onBack: () => c.stage.value = LoginViewStage.signUp,
              );

              children = [
                ReactiveTextField(
                  state: c.email,
                  label: 'label_email'.l10n,
                  style: fonts.bodyMedium,
                  treatErrorAsStatus: false,
                ),
                const SizedBox(height: 25),
                Center(
                  child: Obx(() {
                    final bool enabled =
                        !c.email.isEmpty.value && c.email.error.value == null;

                    return OutlinedRoundedButton(
                      title: Text(
                        'btn_proceed'.l10n,
                        style: fonts.titleLarge!.copyWith(
                          color: enabled
                              ? style.colors.onPrimary
                              : fonts.titleLarge!.color,
                        ),
                      ),
                      onPressed: enabled ? c.email.submit : null,
                      color: style.colors.primary,
                      maxWidth: double.infinity,
                    );
                  }),
                ),
                const SizedBox(height: 25 / 2),
              ];
              break;

            case LoginViewStage.signUp:
              header = ModalPopupHeader(text: 'label_sign_up'.l10n);

              children = [
                _signButton(
                  context,
                  text: 'btn_continue_with_email'.l10n,
                  asset: 'apple',
                  assetWidth: 18.24,
                  assetHeight: 23,
                  onPressed: () =>
                      c.stage.value = LoginViewStage.signUpWithEmail,
                ),
                const SizedBox(height: 25 / 2),
                _signButton(
                  context,
                  text: 'btn_continue_with_phone'.l10n,
                  asset: 'apple',
                  assetWidth: 18.24,
                  assetHeight: 23,
                  onPressed: () =>
                      c.stage.value = LoginViewStage.signUpWithPhone,
                ),
                const SizedBox(height: 25 / 2),
                _signButton(
                  context,
                  text: 'btn_continue_with_apple'.l10n,
                  asset: 'apple',
                  assetWidth: 18.24,
                  assetHeight: 23,
                ),
                const SizedBox(height: 25 / 2),
                _signButton(
                  context,
                  text: 'btn_continue_with_google'.l10n,
                  asset: 'google_logo',
                  assetHeight: 20,
                ),
                const SizedBox(height: 25 / 2),
                _signButton(
                  context,
                  text: 'btn_continue_with_github'.l10n,
                  asset: 'github',
                  assetHeight: 19.99,
                  assetWidth: 20,
                ),
                const SizedBox(height: 25 / 2),
              ];
              break;

            case LoginViewStage.signInWithQr:
              header = ModalPopupHeader(
                onBack: () => c.stage.value = LoginViewStage.signIn,
                text: 'Sign in'.l10n,
              );

              children = [
                // const SizedBox(height: 12),
                Text(
                  'Scan the displayed QR code to sign in.'.l10n,
                  style: fonts.titleLarge,
                ),
                const SizedBox(height: 25),
                Center(
                  child: QrImageView(
                    data: 'https://flutter.dev/',
                    version: QrVersions.auto,
                    size: 300.0,
                  ),
                ),
                // ReactiveTextField(
                //   key: const Key('RecoveryField'),
                //   state: c.login,
                //   label: 'E-mail or phone number'.l10n,
                // ),
                // const SizedBox(height: 25),
                // PrimaryButton(
                //   key: const Key('Proceed'),
                //   title: 'btn_proceed'.l10n,
                //   onPressed:
                //       c.login.isEmpty.value ? null : c.signInWithoutPassword,
                // ),
                const SizedBox(height: 16),
              ];
              break;

            case LoginViewStage.signInWithCode:
              header = ModalPopupHeader(
                onBack: () => c.stage.value = LoginViewStage.signIn,
                text: 'Sign in'.l10n,
              );

              children = [
                Text(
                  'label_recover_account_description'.l10n,
                  style: fonts.titleLarge,
                ),
                const SizedBox(height: 25),
                ReactiveTextField(
                  key: const Key('RecoveryField'),
                  state: c.login,
                  label: 'E-mail or phone number'.l10n,
                ),
                const SizedBox(height: 25),
                PrimaryButton(
                  key: const Key('Proceed'),
                  title: 'btn_proceed'.l10n,
                  onPressed:
                      c.login.isEmpty.value ? null : c.signInWithoutPassword,
                ),
                // const SizedBox(height: 16),
              ];
              break;

            case LoginViewStage.signInWithPassword:
              header = ModalPopupHeader(
                text: 'Sign in'.l10n,
                onBack: () => c.stage.value = LoginViewStage.signIn,
              );

              children = [
                const SizedBox(height: 12),
                ReactiveTextField(
                  key: const Key('UsernameField'),
                  state: c.login,
                  label: 'label_sign_in_input'.l10n,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReactiveTextField(
                      key: const ValueKey('PasswordField'),
                      state: c.password,
                      label: 'label_password'.l10n,
                      obscure: c.obscurePassword.value,
                      onSuffixPressed: c.obscurePassword.toggle,
                      treatErrorAsStatus: false,
                      trailing: SvgImage.asset(
                        'assets/icons/visible_${c.obscurePassword.value ? 'off' : 'on'}.svg',
                        width: 17.07,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 6, 24, 6),
                      child: WidgetButton(
                        onPressed: () {
                          c.stage.value = LoginViewStage.recovery;
                          // if (c.isEmailOrPhone(c.login.text)) {
                          //   c.signInWithoutPassword();
                          // } else {
                          //   c.stage.value = LoginViewStage.noPassword;
                          // }
                        },
                        child: Text(
                          'btn_forgot_password'.l10n,
                          style: fonts.bodyMedium!.copyWith(
                            color: style.colors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25 / 2),
                Obx(() {
                  final bool enabled =
                      !c.login.isEmpty.value && !c.password.isEmpty.value;

                  return PrimaryButton(
                    key: const Key('LoginButton'),
                    title: 'Sign in'.l10n,
                    onPressed: enabled ? c.signIn : null,
                  );
                }),
              ];
              break;

            case LoginViewStage.signIn:
              header = ModalPopupHeader(text: 'Sign in'.l10n);

              children = [
                _signButton(
                  context,
                  text: 'Sign in with password'.l10n,
                  onPressed: () =>
                      c.stage.value = LoginViewStage.signInWithPassword,
                  leading: Icon(
                    Icons.key,
                    color: style.colors.primary,
                  ),
                ),
                const SizedBox(height: 25 / 2),
                _signButton(
                  context,
                  text: 'Sign in with one-time code'.l10n,
                  onPressed: () =>
                      c.stage.value = LoginViewStage.signInWithCode,
                  leading: Icon(
                    Icons.pin,
                    color: style.colors.primary,
                  ),
                ),
                const SizedBox(height: 25 / 2),
                _signButton(
                  context,
                  text: 'Sign in with QR code'.l10n,
                  onPressed: () => c.stage.value = LoginViewStage.signInWithQr,
                  leading: Icon(
                    Icons.qr_code_2,
                    color: style.colors.primary,
                  ),
                ),
                const SizedBox(height: 25 / 2),
                _signButton(
                  context,
                  text: 'Sign in with Apple'.l10n,
                  asset: 'apple',
                  assetWidth: 18.24,
                  assetHeight: 23,
                ),
                const SizedBox(height: 25 / 2),
                _signButton(
                  context,
                  text: 'Sign in with Google'.l10n,
                  asset: 'google_logo',
                  assetHeight: 20,
                ),
                const SizedBox(height: 25 / 2),
                _signButton(
                  context,
                  text: 'Sign in with GitHub'.l10n,
                  asset: 'github',
                  assetHeight: 19.99,
                  assetWidth: 20,
                ),
                const SizedBox(height: 25 / 2),
                // Row(
                //   children: [
                //     Expanded(
                //       child: Container(
                //         height: 1,
                //         width: double.infinity,
                //         color: style.colors.secondaryHighlight,
                //       ),
                //     ),
                //     const SizedBox(width: 8),
                //     Text('OR', style: fonts.headlineSmall),
                //     const SizedBox(width: 8),
                //     Expanded(
                //       child: Container(
                //         height: 1,
                //         width: double.infinity,
                //         color: style.colors.secondaryHighlight,
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 25 / 2),
                // Center(
                //   child: Text.rich(
                //     TextSpan(
                //       children: [
                //         TextSpan(
                //           text: 'Don\'t have an account? '.l10n,
                //           style: fonts.bodyMedium!.copyWith(
                //             color: style.colors.secondary,
                //           ),
                //         ),
                //         TextSpan(
                //           text: 'Sign up.'.l10n,
                //           style: fonts.bodyMedium!.copyWith(
                //             color: style.colors.primary,
                //           ),
                //           recognizer: TapGestureRecognizer()
                //             ..onTap =
                //                 () => c.stage.value = LoginViewStage.signUp,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ];
              break;
          }

          return AnimatedSizeAndFade(
            fadeDuration: const Duration(milliseconds: 250),
            sizeDuration: const Duration(milliseconds: 250),
            fadeInCurve: Curves.easeOut,
            fadeOutCurve: Curves.easeOut,
            sizeCurve: Curves.easeOut,
            child: Scrollbar(
              key: Key('${c.stage.value}'),
              controller: c.scrollController,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ListView(
                      controller: c.scrollController,
                      shrinkWrap: true,
                      children: [
                        header,
                        const SizedBox(height: 12),
                        ...children.map(
                          (e) => Padding(
                            padding: ModalPopup.padding(context),
                            child: e,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  // if (c.stage.value == LoginViewStage.signIn &&
                  //     !context.isNarrow)
                  //   Container(
                  //     width: 400,
                  //     height: 400,
                  //     color: Colors.red,
                  // ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _signButton(
    BuildContext context, {
    String text = '',
    Widget? leading,
    String asset = '',
    double assetWidth = 20,
    double assetHeight = 20,
    EdgeInsets padding = EdgeInsets.zero,
    void Function()? onPressed,
  }) {
    final (style, fonts) = Theme.of(context).styles;

    return Center(
      child: PrefixButton(
        text: text,
        style: fonts.titleMedium!.copyWith(color: style.colors.primary),
        onPressed: onPressed ?? () {},
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 0).add(padding),
          child: leading ??
              SvgImage.asset(
                'assets/icons/$asset.svg',
                width: assetWidth,
                height: assetHeight,
              ),
        ),
      ),
    );
  }
}
