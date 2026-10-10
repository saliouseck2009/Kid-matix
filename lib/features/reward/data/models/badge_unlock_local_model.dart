import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';

part 'badge_unlock_local_model.g.dart';

/// Row of the `badge_unlock` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class BadgeUnlockLocalModel {
  /// Creates a row with every column given.
  const BadgeUnlockLocalModel({
    required this.profileId,
    required this.badgeKey,
    required this.unlockedAt,
    required this.updatedAt,
    this.sessionId,
    this.deletedAt,
  });

  /// Reads a row returned by `sqflite`.
  factory BadgeUnlockLocalModel.fromJson(Map<String, Object?> json) =>
      _$BadgeUnlockLocalModelFromJson(json);

  /// Player.
  final String profileId;

  /// Key of the badge.
  final String badgeKey;

  /// Unlock time, in milliseconds since epoch.
  final int unlockedAt;

  /// Quiz that unlocked it, or `null`.
  final String? sessionId;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$BadgeUnlockLocalModelToJson(this);

  /// Returns the domain unlock of this row.
  BadgeUnlockEntity toEntity() {
    return BadgeUnlockEntity(
      badgeKey: badgeKey,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(unlockedAt),
      sessionId: sessionId,
    );
  }
}
