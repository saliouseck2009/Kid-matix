import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/profile/data/models/sqlite_bool_converter.dart';
import 'package:kid_matix/features/profile/domain/entities/daily_goal.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/timer_mode.dart';

part 'profile_settings_local_model.g.dart';

/// Row of the `profile_settings` table.
@JsonSerializable(fieldRename: FieldRename.snake)
@SqliteBoolConverter()
final class ProfileSettingsLocalModel {
  /// Creates a row with every column given.
  const ProfileSettingsLocalModel({
    required this.profileId,
    required this.timerMode,
    required this.dailyGoalXp,
    required this.isSoundEnabled,
    required this.isVibrationEnabled,
    required this.isReducedMotionEnabled,
    required this.isEverythingUnlocked,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Builds the row of [settings], last changed at [updatedAt].
  factory ProfileSettingsLocalModel.fromEntity({
    required ProfileSettingsEntity settings,
    required DateTime updatedAt,
  }) {
    return ProfileSettingsLocalModel(
      profileId: settings.profileId,
      timerMode: settings.timerMode,
      dailyGoalXp: settings.dailyGoal.xp,
      isSoundEnabled: settings.isSoundEnabled,
      isVibrationEnabled: settings.isVibrationEnabled,
      isReducedMotionEnabled: settings.isReducedMotionEnabled,
      isEverythingUnlocked: settings.isEverythingUnlocked,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite`.
  factory ProfileSettingsLocalModel.fromJson(Map<String, Object?> json) =>
      _$ProfileSettingsLocalModelFromJson(json);

  /// Identifier of the owning profile.
  final String profileId;

  /// Timer behavior, stored by name.
  final TimerMode timerMode;

  /// Daily XP goal.
  final int dailyGoalXp;

  /// Whether sound effects play.
  final bool isSoundEnabled;

  /// Whether answers trigger a vibration.
  final bool isVibrationEnabled;

  /// Whether celebrations are replaced by a still screen.
  final bool isReducedMotionEnabled;

  /// Whether the whole learning path is open.
  final bool isEverythingUnlocked;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$ProfileSettingsLocalModelToJson(this);

  /// Returns the domain settings of this row; an unknown goal falls back to
  /// the default one.
  ProfileSettingsEntity toEntity() {
    return ProfileSettingsEntity(
      profileId: profileId,
      timerMode: timerMode,
      dailyGoal: DailyGoal.values.firstWhere(
        (DailyGoal goal) => goal.xp == dailyGoalXp,
        orElse: () =>
            ProfileSettingsEntity.defaults(profileId: profileId).dailyGoal,
      ),
      isSoundEnabled: isSoundEnabled,
      isVibrationEnabled: isVibrationEnabled,
      isReducedMotionEnabled: isReducedMotionEnabled,
      isEverythingUnlocked: isEverythingUnlocked,
    );
  }
}
