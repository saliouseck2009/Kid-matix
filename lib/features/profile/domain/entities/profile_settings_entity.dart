import 'package:kid_matix/features/profile/domain/entities/daily_goal.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:meta/meta.dart';

/// Game settings of one player.
///
/// Created with the profile using [ProfileSettingsEntity.defaults]; the
/// player changes them from the settings screen (lot F10).
@immutable
final class ProfileSettingsEntity {
  /// Creates the settings with every field given.
  const ProfileSettingsEntity({
    required this.profileId,
    required this.timerMode,
    required this.dailyGoal,
    required this.isSoundEnabled,
    required this.isVibrationEnabled,
    required this.isReducedMotionEnabled,
    required this.isEverythingUnlocked,
  });

  /// Creates the settings of a new player.
  const ProfileSettingsEntity.defaults({required this.profileId})
    : timerMode = TimerMode.normal,
      dailyGoal = DailyGoal.light,
      isSoundEnabled = true,
      isVibrationEnabled = true,
      isReducedMotionEnabled = false,
      isEverythingUnlocked = false;

  /// Identifier of the profile these settings belong to.
  final String profileId;

  /// How the per-question timer behaves.
  final TimerMode timerMode;

  /// XP the player aims to earn each day.
  final DailyGoal dailyGoal;

  /// Whether sound effects play.
  final bool isSoundEnabled;

  /// Whether answers trigger a vibration.
  final bool isVibrationEnabled;

  /// Whether celebrations are replaced by a still screen.
  final bool isReducedMotionEnabled;

  /// Whether every table and stage of the learning path is open.
  final bool isEverythingUnlocked;

  /// Returns a copy with the given fields replaced.
  ProfileSettingsEntity copyWith({
    String? profileId,
    TimerMode? timerMode,
    DailyGoal? dailyGoal,
    bool? isSoundEnabled,
    bool? isVibrationEnabled,
    bool? isReducedMotionEnabled,
    bool? isEverythingUnlocked,
  }) {
    return ProfileSettingsEntity(
      profileId: profileId ?? this.profileId,
      timerMode: timerMode ?? this.timerMode,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
      isReducedMotionEnabled:
          isReducedMotionEnabled ?? this.isReducedMotionEnabled,
      isEverythingUnlocked: isEverythingUnlocked ?? this.isEverythingUnlocked,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProfileSettingsEntity &&
            other.profileId == profileId &&
            other.timerMode == timerMode &&
            other.dailyGoal == dailyGoal &&
            other.isSoundEnabled == isSoundEnabled &&
            other.isVibrationEnabled == isVibrationEnabled &&
            other.isReducedMotionEnabled == isReducedMotionEnabled &&
            other.isEverythingUnlocked == isEverythingUnlocked;
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    timerMode,
    dailyGoal,
    isSoundEnabled,
    isVibrationEnabled,
    isReducedMotionEnabled,
    isEverythingUnlocked,
  );
}
