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

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/api/backend/schema.dart'
    show ConfirmUserEmailErrorCode;
import 'package:messenger/domain/model/application_settings.dart';
import 'package:messenger/domain/model/my_user.dart';
import 'package:messenger/domain/model/ongoing_call.dart';
import 'package:messenger/domain/repository/settings.dart';
import 'package:messenger/domain/service/my_user.dart';
import 'package:messenger/util/obs/obs.dart';

import '/domain/model/user.dart';
import '/l10n/l10n.dart';
import '/provider/gql/exceptions.dart';
import '/ui/page/home/page/chat/controller.dart';
import '/ui/widget/text_field.dart';
import '/util/message_popup.dart';

export 'view.dart';

/// Controller of a [ChatForwardView].
class CallWindowSwitchController extends GetxController {
  CallWindowSwitchController(this._settingsRepository);

  final AbstractSettingsRepository _settingsRepository;

  /// Returns the current [ApplicationSettings] value.
  Rx<ApplicationSettings?> get settings =>
      _settingsRepository.applicationSettings;

  /// Sets the [ApplicationSettings.enablePopups] value.
  Future<void> setPopupsEnabled(bool enabled) =>
      _settingsRepository.setPopupsEnabled(enabled);
}