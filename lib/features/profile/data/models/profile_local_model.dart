import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';

part 'profile_local_model.g.dart';

/// Row of the `profile` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class ProfileLocalModel {
  /// Creates a row with every column given.
  const ProfileLocalModel({
    required this.id,
    required this.nickname,
    required this.normalizedNickname,
    required this.avatar,
    required this.color,
    required this.totalXp,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
    this.remoteAccountId,
    this.lastPlayedAt,
    this.deletedAt,
  });

  /// Builds the row of [profile], last changed at [updatedAt].
  factory ProfileLocalModel.fromEntity({
    required ProfileEntity profile,
    required DateTime updatedAt,
  }) {
    return ProfileLocalModel(
      id: profile.id,
      nickname: profile.nickname,
      normalizedNickname: NicknameRules.normalize(profile.nickname),
      avatar: profile.avatar,
      color: profile.color,
      totalXp: profile.totalXp,
      level: profile.level,
      createdAt: profile.createdAt.millisecondsSinceEpoch,
      lastPlayedAt: profile.lastPlayedAt?.millisecondsSinceEpoch,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite`.
  factory ProfileLocalModel.fromJson(Map<String, Object?> json) =>
      _$ProfileLocalModelFromJson(json);

  /// Primary key, a UUID.
  final String id;

  /// Account on a future server; always `null` in version 1.
  final String? remoteAccountId;

  /// Nickname as displayed.
  final String nickname;

  /// Nickname without case or accents, unique among live rows.
  final String normalizedNickname;

  /// Chosen character, stored by name.
  final ProfileAvatar avatar;

  /// Chosen color, stored by name.
  final ProfileColor color;

  /// XP earned so far.
  final int totalXp;

  /// Player level.
  final int level;

  /// Creation date, in milliseconds since epoch.
  final int createdAt;

  /// End of the last session, in milliseconds since epoch.
  final int? lastPlayedAt;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$ProfileLocalModelToJson(this);

  /// Returns the domain profile of this row.
  ProfileEntity toEntity() {
    final int? lastPlayedAt = this.lastPlayedAt;
    return ProfileEntity(
      id: id,
      nickname: nickname,
      avatar: avatar,
      color: color,
      totalXp: totalXp,
      level: level,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      lastPlayedAt: lastPlayedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastPlayedAt),
    );
  }
}
