import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/reward/domain/entities/xp_award_entity.dart';

part 'xp_award_local_model.g.dart';

/// Row of the `xp_award` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class XpAwardLocalModel {
  /// Creates a row with every column given.
  const XpAwardLocalModel({
    required this.id,
    required this.profileId,
    required this.sourceKey,
    required this.xpEarned,
    required this.earnedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Reads a row returned by `sqflite`.
  factory XpAwardLocalModel.fromJson(Map<String, Object?> json) =>
      _$XpAwardLocalModelFromJson(json);

  /// Creates the row of [award], written at [updatedAt].
  factory XpAwardLocalModel.fromEntity(
    XpAwardEntity award, {
    required DateTime updatedAt,
  }) {
    return XpAwardLocalModel(
      id: award.id,
      profileId: award.profileId,
      sourceKey: award.sourceKey,
      xpEarned: award.xp,
      earnedAt: award.earnedAt.millisecondsSinceEpoch,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Unique identifier.
  final String id;

  /// Player.
  final String profileId;

  /// Game that earned the XP, such as `duel`.
  final String sourceKey;

  /// XP earned.
  final int xpEarned;

  /// When the XP were earned, in milliseconds since epoch.
  final int earnedAt;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$XpAwardLocalModelToJson(this);

  /// Returns the award of this row.
  XpAwardEntity toEntity() {
    return XpAwardEntity(
      id: id,
      profileId: profileId,
      sourceKey: sourceKey,
      xp: xpEarned,
      earnedAt: DateTime.fromMillisecondsSinceEpoch(earnedAt),
    );
  }
}
