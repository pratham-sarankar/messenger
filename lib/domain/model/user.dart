// Copyright © 2022-2024 IT ENGINEERING MANAGEMENT INC,
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

import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '/api/backend/schema.dart';
import '/config.dart';
import '/domain/model/contact.dart';
import '/domain/model_type_id.dart';
import '/l10n/l10n.dart';
import '/util/new_type.dart';
import 'avatar.dart';
import 'chat.dart';
import 'precise_date_time/precise_date_time.dart';
import 'user_call_cover.dart';

part 'user.g.dart';

/// User of a system impersonating a real person.
@HiveType(typeId: ModelTypeId.user)
class User extends HiveObject {
  User(
    this.id,
    this.num, {
    this.name,
    this.bio,
    this.avatar,
    this.callCover,
    this.mutualContactsCount = 0,
    this.online = false,
    this.presenceIndex,
    this.status,
    this.isDeleted = false,
    ChatId? dialog,
    this.isBlocked,
    this.lastSeenAt,
    this.contacts = const [],
  }) : _dialog = dialog;

  /// Unique ID of this [User].
  ///
  /// Once assigned it never changes.
  @HiveField(0)
  final UserId id;

  /// Unique number of this [User].
  ///
  /// [num] is intended for an easier [User] identification by other [User]s.
  /// It's just like a telephone number in a real life.
  ///
  /// [num] allows this [User] to perform a sign-in, when combined with a
  /// password.
  ///
  /// It may be reused by another [User] in future, once this [User] becomes
  /// unreachable (sign-in for this [User] is impossible).
  @HiveField(1)
  final UserNum num;

  /// Name of this [User].
  ///
  /// [name] is not unique and is intended for displaying an [User] in a
  /// well-readable form for an easier [User] identification by other [User]s.
  /// It can be either first name, or last name of an [User], both of them, or
  /// even some nickname. [User] is free to choose how exactly he should be
  /// displayed for other [User]s.
  @HiveField(2)
  UserName? name;

  /// Arbitrary descriptive information about this [User].
  @HiveField(3)
  UserBio? bio;

  /// Avatar of this [User].
  @HiveField(4)
  UserAvatar? avatar;

  /// Call cover of this [User].
  ///
  /// [callCover] is an image helping to identify an [User] visually in
  /// [UserCallCover]s.
  @HiveField(5)
  UserCallCover? callCover;

  /// Number of mutual [ChatContact]s that this [User] has with the
  /// authenticated [MyUser].
  @HiveField(6)
  int mutualContactsCount;

  /// Online state of this [User].
  @HiveField(7)
  bool online;

  /// Presence of this [User].
  @HiveField(8)
  int? presenceIndex;

  Presence? get presence =>
      presenceIndex == null ? null : Presence.values[presenceIndex!];
  set presence(Presence? pres) {
    presenceIndex = pres?.index;
  }

  /// Custom text status of this [User].
  @HiveField(9)
  UserTextStatus? status;

  /// Indicator whether this [User] is deleted.
  @HiveField(10)
  bool isDeleted;

  /// Dialog [Chat] between this [User] and the authenticated [MyUser].
  @HiveField(11)
  ChatId? _dialog;

  /// Indicator whether this [User] is blocked by the authenticated [MyUser].
  @HiveField(12)
  BlocklistRecord? isBlocked;

  /// [PreciseDateTime] when this [User] was seen online last time.
  @HiveField(13)
  PreciseDateTime? lastSeenAt;

  /// List of [NestedChatContact]s this [User] is linked to.
  @HiveField(14)
  final List<NestedChatContact> contacts;

  /// Returns [ChatId] of the [Chat]-dialog with this [User].
  ChatId get dialog => _dialog ?? ChatId.local(id);

  /// Sets the provided [ChatId] as a [dialog] of this [User].
  set dialog(ChatId dialog) => _dialog = dialog;

  /// Returns text representing the title of this [User].
  String get title =>
      contacts.firstOrNull?.name.val ?? name?.val ?? num.toString();

  bool get isBot => bio?.val.startsWith('bot') == true;

  @override
  String toString() => '$runtimeType($id)';
}

/// Unique ID of an [User].
///
/// See more details in [User.id].
@HiveType(typeId: ModelTypeId.userId)
class UserId extends NewType<String> implements Comparable<UserId> {
  const UserId(super.val);

  /// Constructs a [UserId] from the provided [json].
  factory UserId.fromJson(String val) = UserId;

  /// Returns a [String] representing this [UserId].
  String toJson() => val;

  @override
  int compareTo(UserId other) => val.compareTo(other.val);
}

/// Unique number of an [User].
///
/// See more details in [User.num].
@HiveType(typeId: ModelTypeId.userNum)
class UserNum extends NewType<String> {
  const UserNum._(super.val);

  /// Creates an object without any validation.
  const factory UserNum.unchecked(String val) = UserNum._;

  /// Constructs a [UserNum] from the provided [val].
  factory UserNum.fromJson(String val) = UserNum.unchecked;

  factory UserNum(String val) {
    val = val.replaceAll(' ', '');

    if (val.length != 16) {
      throw const FormatException('Must be 16 characters long');
    } else if (!val.isNumericOnly) {
      throw const FormatException('Must be numeric only');
    }

    return UserNum._(val);
  }

  /// Parses the provided [val] as a [UserNum], if [val] meets the validation,
  /// or returns `null` otherwise.
  ///
  /// If [val] contains any spaces, they are omitted.
  static UserNum? tryParse(String val) {
    try {
      return UserNum(val);
    } catch (_) {
      return null;
    }
  }

  /// Returns [UserNum] as [String] formatted in quartets.
  @override
  String toString() {
    String formattedUserNum = '';

    for (int i = 0; i < val.length; i++) {
      if (i % 4 == 0 && i > 0) {
        formattedUserNum += 'space'.l10n;
      }
      formattedUserNum += val[i];
    }
    return formattedUserNum.trim();
  }

  /// Returns a [String] representing this [UserId].
  String toJson() => val;
}

/// Unique login of an [User].
///
/// [UserLogin] allows [User] to perform a sign-in, when combined with a
/// password.
@HiveType(typeId: ModelTypeId.userLogin)
class UserLogin extends NewType<String> {
  const UserLogin._(super.val);

  UserLogin(String val) : super(val) {
    if (val.isNumericOnly) {
      throw const FormatException('Can not contain only numbers');
    } else if (!_regExp.hasMatch(val)) {
      throw const FormatException('Does not match validation RegExp');
    }
  }

  /// Creates an object without any validation.
  const factory UserLogin.unchecked(String val) = UserLogin._;

  /// Constructs a [UserLogin] from the provided [val].
  factory UserLogin.fromJson(String val) = UserLogin.unchecked;

  /// Regular expression for basic [UserLogin] validation.
  static final RegExp _regExp = RegExp(r'^[a-z0-9][a-z0-9_-]{1,18}[a-z0-9]$');

  /// Parses the provided [val] as a [UserLogin], if [val] meets the validation,
  /// or returns `null` otherwise.
  static UserLogin? tryParse(String val) {
    try {
      return UserLogin(val);
    } catch (_) {
      return null;
    }
  }

  /// Returns a [String] representing this [UserLogin].
  String toJson() => val;
}

/// Name of an [User].
///
/// See more details in [User.name].
@HiveType(typeId: ModelTypeId.userName)
class UserName extends NewType<String> {
  const UserName._(super.val);

  UserName(String val) : super(val) {
    if (!_regExp.hasMatch(val)) {
      throw const FormatException('Does not match validation RegExp');
    }
  }

  /// Creates an object without any validation.
  const factory UserName.unchecked(String val) = UserName._;

  /// Constructs a [UserName] from the provided [val].
  factory UserName.fromJson(String val) = UserName.unchecked;

  /// Regular expression for basic [UserName] validation.
  static final RegExp _regExp = RegExp(r'^[^\s].{0,98}[^\s]$');

  /// Parses the provided [val] as a [UserName], if [val] meets the validation,
  /// or returns `null` otherwise.
  static UserName? tryParse(String val) {
    try {
      return UserName(val);
    } catch (_) {
      return null;
    }
  }

  /// Returns a [String] representing this [UserName].
  String toJson() => val;
}

/// Password of an [User].
///
/// Password allows [User] to perform a sign-in, when combined with a
/// [UserLogin], [UserNum], [UserEmail] or [UserPhone].
class UserPassword extends NewType<String> {
  const UserPassword._(super.val);

  UserPassword(String val) : super(val) {
    if (val.isEmpty) {
      throw const FormatException('Must not be empty');
    } else if (val.length > 250) {
      throw const FormatException('Must contain no more than 250 characters');
    } else if (!_regExp.hasMatch(val)) {
      throw const FormatException('Does not match validation RegExp');
    }
  }

  /// Creates an object without any validation.
  const factory UserPassword.unchecked(String val) = UserPassword._;

  /// Constructs a [UserPassword] from the provided [val].
  factory UserPassword.fromJson(String val) = UserPassword.unchecked;

  /// Regular expression for basic [UserPassword] validation.
  static final RegExp _regExp = RegExp(r'^[^\s](.{0,248}[^\s])?$');

  /// Parses the provided [val] as a [UserPassword], if [val] meets the
  /// validation, or returns `null` otherwise.
  static UserPassword? tryParse(String val) {
    try {
      return UserPassword(val);
    } catch (_) {
      return null;
    }
  }

  /// Returns a [String] representing this [UserPassword].
  String toJson() => val;
}

/// Email address of an [User].
@HiveType(typeId: ModelTypeId.userEmail)
class UserEmail extends NewType<String> {
  const UserEmail._(super.val);

  UserEmail(String val) : super(val) {
    if (!EmailValidator.validate(val)) {
      throw const FormatException('Does not match validation RegExp');
    }
  }

  /// Creates an object without any validation.
  const factory UserEmail.unchecked(String val) = UserEmail._;

  /// Constructs a [UserEmail] from the provided [val].
  factory UserEmail.fromJson(String val) = UserEmail.unchecked;

  /// Parses the provided [val] as a [UserEmail], if [val] meets the validation,
  /// or returns `null` otherwise.
  static UserEmail? tryParse(String val) {
    try {
      return UserEmail(val);
    } catch (_) {
      return null;
    }
  }

  /// Returns a [String] representing this [UserEmail].
  String toJson() => val;
}

/// Arbitrary descriptive information about a [User].
@HiveType(typeId: ModelTypeId.userBio)
class UserBio extends NewType<String> {
  const UserBio._(super.val);

  factory UserBio(String val) {
    if (val.isEmpty) {
      throw const FormatException('Must not be empty');
    } else if (val.length > 4096) {
      throw const FormatException('Must not be longer than 4096 symbols');
    }

    return UserBio._(val);
  }

  /// Creates an object without any validation.
  const factory UserBio.unchecked(String val) = UserBio._;

  /// Constructs a [UserBio] from the provided [val].
  factory UserBio.fromJson(String val) = UserBio.unchecked;

  /// Parses the provided [val] as a [UserBio], if [val] meets the validation,
  /// or returns `null` otherwise.
  static UserBio? tryParse(String val) {
    try {
      return UserBio(val);
    } catch (_) {
      return null;
    }
  }

  /// Returns a [String] representing this [UserBio].
  String toJson() => val;
}

/// Phone number of an [User].
@HiveType(typeId: ModelTypeId.userPhone)
class UserPhone extends NewType<String> {
  const UserPhone._(super.val);

  UserPhone(String val) : super(val) {
    if (!val.startsWith('+')) {
      throw const FormatException('Must start with plus');
    }

    if (val.length < 8) {
      throw const FormatException('Must contain no less than 8 symbols');
    }

    if (!_regExp.hasMatch(val)) {
      throw const FormatException('Does not match validation RegExp');
    }
  }

  /// Creates an object without any validation.
  const factory UserPhone.unchecked(String val) = UserPhone._;

  /// Constructs a [UserPhone] from the provided [val].
  factory UserPhone.fromJson(String val) = UserPhone.unchecked;

  /// Regular expression for basic [UserPhone] validation.
  static final RegExp _regExp = RegExp(
    r'^\+[0-9]{0,3}[\s]?[(]?[0-9]{0,3}[)]?[-\s]?[0-9]{0,4}[-\s]?[0-9]{0,4}[-\s]?[0-9]{0,4}$',
  );

  /// Parses the provided [val] as a [UserPhone], if [val] meets the validation,
  /// or returns `null` otherwise.
  static UserPhone? tryParse(String val) {
    try {
      return UserPhone(val);
    } catch (_) {
      return null;
    }
  }

  /// Returns a [String] representing this [UserPhone].
  String toJson() => val;
}

/// Direct link to a `Chat`.
@HiveType(typeId: ModelTypeId.chatDirectLink)
@JsonSerializable()
class ChatDirectLink {
  ChatDirectLink({
    required this.slug,
    this.usageCount = 0,
  });

  /// Constructs a [ChatDirectLink] from the provided [json].
  factory ChatDirectLink.fromJson(Map<String, dynamic> json) =>
      _$ChatDirectLinkFromJson(json);

  /// Unique slug associated with this [ChatDirectLink].
  @HiveField(0)
  ChatDirectLinkSlug slug;

  /// Number of times this [ChatDirectLink] has been used.
  @HiveField(1)
  int usageCount;

  @override
  bool operator ==(Object other) =>
      other is ChatDirectLink &&
      slug == other.slug &&
      usageCount == other.usageCount;

  @override
  int get hashCode => Object.hash(slug, usageCount);

  /// Returns a [Map] representing this [ChatDirectLink].
  Map<String, dynamic> toJson() => _$ChatDirectLinkToJson(this);
}

/// Slug of a [ChatDirectLink].
@HiveType(typeId: ModelTypeId.chatDirectLinkSlug)
class ChatDirectLinkSlug extends NewType<String> {
  const ChatDirectLinkSlug._(super.val);

  ChatDirectLinkSlug(String val) : super(val) {
    if (val.length > 100) {
      throw const FormatException('Must contain no more than 100 characters');
    } else if (val.isEmpty) {
      throw const FormatException('Must not be empty');
    } else if (!_regExp.hasMatch(val)) {
      throw const FormatException('Does not match validation RegExp');
    }
  }

  /// Creates an object without any validation.
  const factory ChatDirectLinkSlug.unchecked(String val) = ChatDirectLinkSlug._;

  /// Constructs a [ChatDirectLinkSlug] from the provided [val].
  factory ChatDirectLinkSlug.fromJson(String val) =
      ChatDirectLinkSlug.unchecked;

  /// Creates a random [ChatDirectLinkSlug] of the provided [length].
  factory ChatDirectLinkSlug.generate([int length = 10]) {
    final Random r = Random();
    const String chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890_-';

    return ChatDirectLinkSlug(
      List.generate(length, (i) {
        // `-` and `_` being the last might not be parsed as a link by some
        // applications.
        if (i == length - 1) {
          final str = chars.replaceFirst('-', '').replaceFirst('_', '');
          return str[r.nextInt(str.length)];
        }

        return chars[r.nextInt(chars.length)];
      }).join(),
    );
  }

  /// Regular expression for basic [ChatDirectLinkSlug] validation.
  static final RegExp _regExp = RegExp(r'^[A-Za-z0-9_-]{1,100}$');

  /// Parses the provided [val] as a [ChatDirectLinkSlug], if [val] meets the
  /// validation, or returns `null` otherwise.
  ///
  /// If [val] starts with [Config.link], then that part is omitted.
  static ChatDirectLinkSlug? tryParse(String val) {
    if (val.startsWith('${Config.link}/')) {
      val = val.substring(Config.link.length + 1);
    }

    try {
      return ChatDirectLinkSlug(val);
    } catch (_) {
      return null;
    }
  }

  /// Returns a [String] representing this [ChatDirectLinkSlug].
  String toJson() => val;
}

/// Status of an [User].
@HiveType(typeId: ModelTypeId.userTextStatus)
class UserTextStatus extends NewType<String> {
  const UserTextStatus._(super.val);

  UserTextStatus(String val) : super(val) {
    if (val.length > 25) {
      throw const FormatException('Must contain no more than 25 characters');
    } else if (val.isEmpty) {
      throw const FormatException('Must not be empty');
    }
  }

  /// Creates an object without any validation.
  const factory UserTextStatus.unchecked(String val) = UserTextStatus._;

  /// Constructs a [UserTextStatus] from the provided [val].
  factory UserTextStatus.fromJson(String val) = UserTextStatus.unchecked;

  /// Parses the provided [val] as a [UserTextStatus], if [val] meets the
  /// validation, or returns `null` otherwise.
  static UserTextStatus? tryParse(String val) {
    try {
      return UserTextStatus(val);
    } catch (_) {
      return null;
    }
  }

  /// Returns a [String] representing this [UserTextStatus].
  String toJson() => val;
}

/// [User]'s record in a blocklist of the authenticated [MyUser].
@HiveType(typeId: ModelTypeId.blocklistRecord)
@JsonSerializable()
class BlocklistRecord implements Comparable<BlocklistRecord> {
  BlocklistRecord({
    required this.userId,
    this.reason,
    required this.at,
  });

  /// Constructs a [BlocklistRecord] from the provided [json].
  factory BlocklistRecord.fromJson(Map<String, dynamic> json) =>
      _$BlocklistRecordFromJson(json);

  /// Blocked [User].
  @HiveField(0)
  final UserId userId;

  /// Reason of why the [User] was blocked.
  @HiveField(1)
  final BlocklistReason? reason;

  /// [PreciseDateTime] when the [User] was blocked.
  @HiveField(2)
  final PreciseDateTime at;

  @override
  bool operator ==(Object other) =>
      other is BlocklistRecord && at == other.at && reason == other.reason;

  @override
  int get hashCode => Object.hash(at, reason);

  @override
  int compareTo(BlocklistRecord other) {
    final int result = other.at.compareTo(at);
    return result == 0 ? userId.compareTo(other.userId) : result;
  }

  /// Returns a [Map] representing this [BlocklistRecord].
  Map<String, dynamic> toJson() => _$BlocklistRecordToJson(this);
}

/// Reason of blocking a [User] by the authenticated [MyUser].
@JsonSerializable()
@HiveType(typeId: ModelTypeId.blocklistReason)
class BlocklistReason extends NewType<String> {
  const BlocklistReason(super.val);

  /// Constructs a [BlocklistRecord] from the provided [val].
  factory BlocklistReason.fromJson(String val) = BlocklistReason;

  /// Returns a [String] representing this [BlocklistReason].
  String toJson() => val;
}

/// Record in an address book of the authenticated [MyUser].
@JsonSerializable()
@HiveType(typeId: ModelTypeId.nestedChatContact)
class NestedChatContact {
  NestedChatContact(this.id, this.name);

  /// Constructs a [NestedChatContact] from the provided [ChatContact].
  NestedChatContact.from(ChatContact contact)
      : id = contact.id,
        name = contact.name;

  /// Constructs a [NestedChatContact] from the provided [json].
  factory NestedChatContact.fromJson(Map<String, dynamic> json) =>
      _$NestedChatContactFromJson(json);

  /// Unique ID of this [NestedChatContact].
  @HiveField(0)
  final ChatContactId id;

  /// Custom [UserName] of this [NestedChatContact] given by the authenticated
  /// [MyUser].
  @HiveField(1)
  UserName name;

  /// Returns a [Map] representing this [NestedChatContact].
  Map<String, dynamic> toJson() => _$NestedChatContactToJson(this);
}
