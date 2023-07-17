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
import 'package:messenger/domain/service/my_user.dart';
import 'package:messenger/provider/gql/graphql.dart';
import 'package:messenger/util/message_popup.dart';

import '/api/backend/schema.dart' show CreateSessionErrorCode;
import '/domain/model/my_user.dart';
import '/domain/model/user.dart';
import '/domain/service/auth.dart';
import '/l10n/l10n.dart';
import '/provider/gql/exceptions.dart'
    show
        AddUserEmailException,
        ConfirmUserEmailException,
        ConnectionException,
        CreateSessionException,
        RecoverUserPasswordException,
        ResetUserPasswordException,
        ValidateUserPasswordRecoveryCodeException;
import '/routes.dart';
import '/ui/widget/text_field.dart';

/// Possible [LoginView] flow stage.
enum LoginViewStage {
  recovery,
  recoveryCode,
  recoveryPassword,
  signIn,
  signInWithPassword,
  signInWithCode,
  signInWithQr,
  signUp,
  noPassword,
  noPasswordCode,
  code,
}

/// [GetxController] of a [LoginView].
class LoginController extends GetxController {
  LoginController(this._authService);

  /// [TextFieldState] of a login text input.
  late final TextFieldState login;

  /// [TextFieldState] of a password text input.
  late final TextFieldState password;

  /// [TextFieldState] of a recovery text input.
  late final TextFieldState recovery;

  /// [TextFieldState] of a recovery code text input.
  late final TextFieldState recoveryCode;

  /// [TextFieldState] of a new password text input.
  late final TextFieldState newPassword;

  /// [TextFieldState] of a repeat password text input.
  late final TextFieldState repeatPassword;

  late final TextFieldState email = TextFieldState(
    onChanged: (s) {
      try {
        if (s.text.isNotEmpty) {
          UserEmail(s.text.toLowerCase());
        }

        s.error.value = null;
      } on FormatException {
        s.error.value = 'err_incorrect_email'.l10n;
      }
    },
    onSubmitted: (s) async {
      try {
        await _authService.register();

        final GraphQlProvider graphQlProvider = Get.find();
        await graphQlProvider.addUserEmail(UserEmail(email.text));
      } on AddUserEmailException catch (e) {
        s.error.value = e.toMessage();
      } catch (_) {
        s.error.value = 'err_data_transfer'.l10n;
        s.unsubmit();
      }

      stage.value = LoginViewStage.code;
      // await _authService.register();

      // router.validateEmail = true;
      // router.home();

      // while (!Get.isRegistered<MyUserService>()) {
      //   await Future.delayed(const Duration(milliseconds: 20));
      // }

      // final MyUserService myUserService = Get.find();
      // await myUserService.addUserEmail(UserEmail(email.text));
    },
  );

  late final TextFieldState emailCode = TextFieldState(
    onChanged: (s) => s.error.value = null,
    onSubmitted: (s) async {
      try {
        final GraphQlProvider graphQlProvider = Get.find();
        await graphQlProvider.confirmEmailCode(ConfirmationCode(s.text));
        router.noIntroduction = true;
        router.home();
      } on ConfirmUserEmailException catch (e) {
        s.error.value = e.toMessage();
      } catch (_) {
        s.error.value = 'err_data_transfer'.l10n;
        s.unsubmit();
      }
    },
  );

  /// Indicator whether the [password] should be obscured.
  final RxBool obscurePassword = RxBool(true);

  /// Indicator whether the [newPassword] should be obscured.
  final RxBool obscureNewPassword = RxBool(true);

  /// Indicator whether the [repeatPassword] should be obscured.
  final RxBool obscureRepeatPassword = RxBool(true);

  /// Indicator whether the password has been reset.
  final RxBool recovered = RxBool(false);

  /// [ScrollController] to pass to a [Scrollbar].
  final ScrollController scrollController = ScrollController();

  /// [LoginViewStage] currently being displayed.
  final Rx<LoginViewStage> stage = Rx(LoginViewStage.signUp);

  /// Authentication service providing the authentication capabilities.
  final AuthService _authService;

  /// [UserNum] that was provided in [recoverAccess] used to [validateCode] and
  /// [resetUserPassword].
  UserNum? _recoveryNum;

  /// [UserEmail] that was provided in [recoverAccess] used to [validateCode]
  /// and [resetUserPassword].
  UserEmail? _recoveryEmail;

  /// [UserPhone] that was provided in [recoverAccess] used to [validateCode]
  /// and [resetUserPassword].
  UserPhone? _recoveryPhone;

  /// [UserLogin] that was provided in [recoverAccess] used to [validateCode]
  /// and [resetUserPassword].
  UserLogin? _recoveryLogin;

  /// Current authentication status.
  Rx<RxStatus> get authStatus => _authService.status;

  @override
  void onInit() {
    login = TextFieldState(
      onChanged: (s) => s.error.value = null,
      onSubmitted: (s) => password.focus.requestFocus(),
    );

    password = TextFieldState(
      onChanged: (s) => s.error.value = null,
      onSubmitted: (s) => signIn(),
    );

    recovery = TextFieldState(
      onChanged: (s) => s.error.value = null,
      onSubmitted: (s) => recoverAccess(),
    );

    recoveryCode = TextFieldState(
      onChanged: (s) => s.error.value = null,
      onSubmitted: (s) => validateCode(),
    );

    newPassword = TextFieldState(
      onChanged: (s) {
        s.error.value = null;
        repeatPassword.error.value = null;
      },
      onSubmitted: (s) => repeatPassword.focus.requestFocus(),
    );
    repeatPassword = TextFieldState(
      onChanged: (s) {
        s.error.value = null;
        newPassword.error.value = null;

        if (s.text != newPassword.text && newPassword.isValidated) {
          s.error.value = 'err_passwords_mismatch'.l10n;
        }
      },
      onSubmitted: (s) => stage.value == LoginViewStage.signUp
          ? register()
          : resetUserPassword(),
    );

    super.onInit();
  }

  /// Signs in and redirects to the [Routes.home] page.
  ///
  /// Username is [login]'s text and the password is [password]'s text.
  Future<void> signIn() async {
    UserLogin? userLogin;
    UserNum? num;
    UserEmail? email;
    UserPhone? phone;

    login.error.value = null;
    password.error.value = null;

    if (login.text.isEmpty) {
      login.error.value = 'err_account_not_found'.l10n;
      return;
    }

    try {
      userLogin = UserLogin(login.text.toLowerCase());
    } catch (e) {
      // No-op.
    }

    try {
      num = UserNum(login.text);
    } catch (e) {
      // No-op.
    }

    try {
      email = UserEmail(login.text.toLowerCase());
    } catch (e) {
      // No-op.
    }

    try {
      phone = UserPhone(login.text);
    } catch (e) {
      // No-op.
    }

    if (password.text.isEmpty) {
      password.error.value = 'err_password_empty'.l10n;
      return;
    }

    if (userLogin == null && num == null && email == null && phone == null) {
      login.error.value = 'err_account_not_found'.l10n;
      return;
    }

    try {
      login.status.value = RxStatus.loading();
      password.status.value = RxStatus.loading();
      await _authService.signIn(
        UserPassword(password.text),
        login: userLogin,
        num: num,
        email: email,
        phone: phone,
      );

      router.home();
    } on FormatException {
      password.error.value = 'err_incorrect_password'.l10n;
    } on CreateSessionException catch (e) {
      switch (e.code) {
        case CreateSessionErrorCode.wrongPassword:
          password.error.value = e.toMessage();
          break;

        case CreateSessionErrorCode.artemisUnknown:
          password.error.value = 'err_data_transfer'.l10n;
          rethrow;
      }
    } on ConnectionException {
      password.unsubmit();
      password.error.value = 'err_data_transfer'.l10n;
    } catch (e) {
      password.unsubmit();
      password.error.value = 'err_data_transfer'.l10n;
      rethrow;
    } finally {
      login.status.value = RxStatus.empty();
      password.status.value = RxStatus.empty();
    }
  }

  /// Initiates password recovery for the [MyUser] identified by the provided
  /// [recovery] input and stores the parsed value.
  Future<void> recoverAccess() async {
    recovery.editable.value = false;
    recovery.status.value = RxStatus.loading();
    recovery.error.value = null;

    _recoveryLogin = _recoveryNum = _recoveryPhone = _recoveryEmail = null;

    if (recovery.text.isEmpty) {
      recovery.status.value = RxStatus.empty();
      recovery.editable.value = true;
      recovery.error.value = 'err_account_not_found'.l10n;
      return;
    }

    // Parse the [recovery] input.
    try {
      _recoveryNum = UserNum(recovery.text);
    } catch (e) {
      try {
        _recoveryPhone = UserPhone(recovery.text);
      } catch (e) {
        try {
          _recoveryLogin = UserLogin(recovery.text.toLowerCase());
        } catch (e) {
          try {
            _recoveryEmail = UserEmail(recovery.text);
          } catch (e) {
            // No-op.
          }
        }
      }
    }

    try {
      await _authService.recoverUserPassword(
        login: _recoveryLogin,
        num: _recoveryNum,
        email: _recoveryEmail,
        phone: _recoveryPhone,
      );

      stage.value = LoginViewStage.recoveryCode;
      recovery.status.value = RxStatus.success();
      recovery.editable.value = false;
    } on FormatException {
      recovery.error.value = 'err_account_not_found'.l10n;
    } on ArgumentError {
      recovery.error.value = 'err_account_not_found'.l10n;
    } on RecoverUserPasswordException catch (e) {
      recovery.error.value = e.toMessage();
    } catch (e) {
      recovery.unsubmit();
      recovery.error.value = 'err_data_transfer'.l10n;
      rethrow;
    } finally {
      recovery.status.value = RxStatus.empty();
      recovery.editable.value = true;
    }
  }

  /// Validates the provided password recovery [ConfirmationCode] for the
  /// [MyUser] identified by the provided in [recoverAccess] identity.
  Future<void> validateCode() async {
    recoveryCode.editable.value = false;
    recoveryCode.status.value = RxStatus.loading();
    recoveryCode.error.value = null;

    if (recoveryCode.text.isEmpty) {
      recoveryCode.editable.value = true;
      recoveryCode.status.value = RxStatus.empty();
      recoveryCode.error.value = 'err_input_empty'.l10n;
      return;
    }

    try {
      await _authService.validateUserPasswordRecoveryCode(
        login: _recoveryLogin,
        num: _recoveryNum,
        email: _recoveryEmail,
        phone: _recoveryPhone,
        code: ConfirmationCode(recoveryCode.text.toLowerCase()),
      );

      recoveryCode.editable.value = false;
      recoveryCode.status.value = RxStatus.success();
      stage.value = LoginViewStage.recoveryPassword;
    } on FormatException {
      recoveryCode.error.value = 'err_wrong_recovery_code'.l10n;
    } on ArgumentError {
      recoveryCode.error.value = 'err_wrong_recovery_code'.l10n;
    } on ValidateUserPasswordRecoveryCodeException catch (e) {
      recoveryCode.error.value = e.toMessage();
    } catch (e) {
      recoveryCode.unsubmit();
      recoveryCode.error.value = 'err_data_transfer'.l10n;
      rethrow;
    } finally {
      recoveryCode.editable.value = true;
      recoveryCode.status.value = RxStatus.empty();
    }
  }

  /// Resets password for the [MyUser] identified by the provided in
  /// [recoverAccess] identity and [ConfirmationCode].
  Future<void> resetUserPassword() async {
    if (newPassword.error.value != null || repeatPassword.error.value != null) {
      return;
    }

    repeatPassword.status.value = RxStatus.empty();

    if (newPassword.text.isEmpty) {
      newPassword.error.value = 'err_input_empty'.l10n;
      newPassword.editable.value = true;
      repeatPassword.editable.value = true;
      return;
    }

    if (repeatPassword.text.isEmpty) {
      repeatPassword.error.value = 'err_input_empty'.l10n;
      return;
    }

    try {
      UserPassword(newPassword.text);
    } catch (e) {
      newPassword.error.value = 'err_incorrect_input'.l10n;
      return;
    }

    try {
      UserPassword(repeatPassword.text);
    } catch (e) {
      repeatPassword.error.value = 'err_incorrect_input'.l10n;
      return;
    }

    if (newPassword.text != repeatPassword.text) {
      repeatPassword.error.value = 'err_passwords_mismatch'.l10n;
      return;
    }

    newPassword.editable.value = false;
    repeatPassword.editable.value = false;
    repeatPassword.status.value = RxStatus.loading();

    try {
      await _authService.resetUserPassword(
        login: _recoveryLogin,
        num: _recoveryNum,
        email: _recoveryEmail,
        phone: _recoveryPhone,
        code: ConfirmationCode(recoveryCode.text.toLowerCase()),
        newPassword: UserPassword(newPassword.text),
      );

      recovered.value = true;
      stage.value = LoginViewStage.signIn;
    } on FormatException {
      repeatPassword.error.value = 'err_incorrect_input'.l10n;
    } on ArgumentError {
      repeatPassword.error.value = 'err_incorrect_input'.l10n;
    } on ResetUserPasswordException catch (e) {
      repeatPassword.error.value = e.toMessage();
    } catch (e) {
      repeatPassword.error.value = 'err_data_transfer'.l10n;
      rethrow;
    } finally {
      repeatPassword.status.value = RxStatus.empty();
      newPassword.editable.value = true;
      repeatPassword.editable.value = true;
    }
  }

  Future<void> register() async {
    await _authService.register();
    router.validateEmail = true;
    router.home();

    while (!Get.isRegistered<MyUserService>()) {
      await Future.delayed(const Duration(milliseconds: 20));
    }

    final MyUserService myUserService = Get.find();
    await myUserService.addUserEmail(UserEmail(email.text));
    await myUserService.updateUserPassword(
      newPassword: UserPassword(repeatPassword.text),
    );
  }

  Future<void> signInWithoutPassword() async {
    stage.value = LoginViewStage.noPasswordCode;
    recoveryCode.clear();
  }

  Future<void> signInWithCode(String code) async {}

  bool isEmailOrPhone(String text) {
    try {
      UserEmail(text);
      return true;
    } catch (_) {
      try {
        UserPhone(text);
        return true;
      } catch (_) {
        return false;
      }
    }
  }
}
