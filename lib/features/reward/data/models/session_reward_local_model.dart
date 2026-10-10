import 'package:json_annotation/json_annotation.dart';

part 'session_reward_local_model.g.dart';

/// Row of the `session_reward` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class SessionRewardLocalModel {
  /// Creates a row with every column given.
  const SessionRewardLocalModel({
    required this.sessionId,
    required this.profileId,
    required this.xpEarned,
    required this.xpVersion,
    required this.earnedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Reads a row returned by `sqflite`.
  factory SessionRewardLocalModel.fromJson(Map<String, Object?> json) =>
      _$SessionRewardLocalModelFromJson(json);

  /// Quiz session.
  final String sessionId;

  /// Player.
  final String profileId;

  /// XP earned.
  final int xpEarned;

  /// Version of the XP rules that counted them.
  final int xpVersion;

  /// End of the quiz, in milliseconds since epoch.
  final int earnedAt;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$SessionRewardLocalModelToJson(this);
}
