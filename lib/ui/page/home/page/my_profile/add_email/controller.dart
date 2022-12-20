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

import 'dart:async';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/api/backend/schema.dart'
    show ConfirmUserEmailErrorCode;
import 'package:messenger/domain/model/my_user.dart';
import 'package:messenger/domain/service/my_user.dart';

import '/domain/model/user.dart';
import '/l10n/l10n.dart';
import '/provider/gql/exceptions.dart';
import '/ui/page/home/page/chat/controller.dart';
import '/ui/widget/text_field.dart';
import '/util/message_popup.dart';

export 'view.dart';

enum AddEmailFlowStage {
  code,
}

/// Controller of a [ChatForwardView].
class AddEmailController extends GetxController {
  AddEmailController(this._myUserService, {this.initial, this.pop});

  final void Function()? pop;
  final UserEmail? initial;

  late final TextFieldState email;
  late final TextFieldState emailCode;

  final RxBool resent = RxBool(false);

  /// Timeout of a [resendEmail] action.
  final RxInt resendEmailTimeout = RxInt(0);

  final Rx<AddEmailFlowStage?> stage = Rx(null);

  final MyUserService _myUserService;

  /// [Timer] to decrease [resendEmailTimeout].
  Timer? _resendEmailTimer;

  /// Returns current [MyUser] value.
  Rx<MyUser?> get myUser => _myUserService.myUser;

  @override
  void onInit() {
    email = TextFieldState(
      text: initial?.val,
      onChanged: (s) {
        s.error.value = null;
        s.unsubmit();
      },
      onSubmitted: (s) async {
        UserEmail? email;
        try {
          email = UserEmail(s.text);

          if (myUser.value!.emails.confirmed.contains(email) ||
              myUser.value?.emails.unconfirmed == email) {
            s.error.value = 'err_you_already_add_this_email'.l10n;
          }
        } on FormatException {
          s.error.value = 'err_incorrect_email'.l10n;
        }

        if (s.error.value == null) {
          s.editable.value = false;
          s.status.value = RxStatus.loading();

          try {
            await _myUserService.addUserEmail(email!);
            _setResendEmailTimer(true);
            stage.value = AddEmailFlowStage.code;
          } on FormatException {
            s.error.value = 'err_incorrect_email'.l10n;
          } on AddUserEmailException catch (e) {
            s.error.value = e.toMessage();
          } catch (e) {
            s.error.value = 'err_data_transfer'.l10n;
            s.unsubmit();
            rethrow;
          } finally {
            s.editable.value = true;
            s.status.value = RxStatus.empty();
          }
        }
      },
    );

    emailCode = TextFieldState(
      onChanged: (s) {
        s.error.value = null;
        s.unsubmit();
      },
      onSubmitted: (s) async {
        if (s.text.isEmpty) {
          s.error.value = 'err_input_empty'.l10n;
        }

        if (s.error.value == null) {
          s.editable.value = false;
          s.status.value = RxStatus.loading();
          try {
            await _myUserService.confirmEmailCode(ConfirmationCode(s.text));
            pop?.call();
            s.clear();
          } on FormatException {
            s.error.value = 'err_wrong_recovery_code'.l10n;
          } on ConfirmUserEmailException catch (e) {
            s.error.value = e.toMessage();
          } catch (e) {
            s.error.value = 'err_data_transfer'.l10n;
            s.unsubmit();
            rethrow;
          } finally {
            s.editable.value = true;
            s.status.value = RxStatus.empty();
          }
        }
      },
    );

    if (initial != null) {
      stage.value = AddEmailFlowStage.code;
    }

    super.onInit();
  }

  @override
  void onClose() {
    _setResendEmailTimer(false);
    super.onClose();
  }

  /// Resend [ConfirmationCode] to [UserEmail] specified in the [email] field to
  /// [MyUser.emails].
  Future<void> resendEmail() async {
    try {
      await _myUserService.resendEmail();
      resent.value = true;
      _setResendEmailTimer(true);
    } on ResendUserEmailConfirmationException catch (e) {
      emailCode.error.value = e.toMessage();
    } catch (e) {
      MessagePopup.error(e);
      rethrow;
    }
  }

  /// Starts or stops [resendEmailTimer] based on [enabled] value.
  void _setResendEmailTimer([bool enabled = true]) {
    if (enabled) {
      resendEmailTimeout.value = 30;
      _resendEmailTimer = Timer.periodic(
        const Duration(milliseconds: 1500),
        (_) {
          resendEmailTimeout.value--;
          if (resendEmailTimeout.value <= 0) {
            resendEmailTimeout.value = 0;
            _resendEmailTimer?.cancel();
            _resendEmailTimer = null;
          }
        },
      );
    } else {
      resendEmailTimeout.value = 0;
      _resendEmailTimer?.cancel();
      _resendEmailTimer = null;
    }
  }
}