import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';

part 'streak_local_model.g.dart';

/// Row of the `streak` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class StreakLocalModel {
  /// Creates a row with every column given.
  const StreakLocalModel({
    required this.profileId,
    required this.currentStreak,
    required this.bestStreak,
    required this.updatedAt,
    this.lastPlayedDay,
    this.jokerUsedWeek,
    this.deletedAt,
  });

  /// Builds the row of [streak] for [profileId], written at [updatedAt].
  factory StreakLocalModel.fromEntity({
    required String profileId,
    required StreakEntity streak,
    required DateTime updatedAt,
  }) {
    return StreakLocalModel(
      profileId: profileId,
      currentStreak: streak.current,
      bestStreak: streak.best,
      lastPlayedDay: streak.lastPlayedDay?.millisecondsSinceEpoch,
      jokerUsedWeek: streak.jokerUsedWeek?.millisecondsSinceEpoch,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite`.
  factory StreakLocalModel.fromJson(Map<String, Object?> json) =>
      _$StreakLocalModelFromJson(json);

  /// Player.
  final String profileId;

  /// Streak as last recorded.
  final int currentStreak;

  /// Longest streak.
  final int bestStreak;

  /// Last day with a completed quiz, in milliseconds since epoch.
  final int? lastPlayedDay;

  /// Monday of the week whose joker was used, in milliseconds since epoch.
  final int? jokerUsedWeek;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$StreakLocalModelToJson(this);

  /// Returns the domain streak of this row.
  StreakEntity toEntity() {
    final int? lastDay = lastPlayedDay;
    final int? jokerWeek = jokerUsedWeek;
    return StreakEntity(
      current: currentStreak,
      best: bestStreak,
      lastPlayedDay: lastDay == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastDay),
      jokerUsedWeek: jokerWeek == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(jokerWeek),
    );
  }
}
