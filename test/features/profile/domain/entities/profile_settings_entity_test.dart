import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/profile/domain/entities/daily_goal.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';

void main() {
  group('ProfileSettingsEntity', () {
    test('defaults to a 20 XP daily goal with the normal timer', () {
      // Arrange
      const int expectedDailyGoalXp = 20;
      // Act
      const ProfileSettingsEntity actualSettings =
          ProfileSettingsEntity.defaults(profileId: 'profile-1');
      // Assert
      expect(actualSettings.dailyGoal.xp, expectedDailyGoalXp);
      expect(actualSettings.timerMode, TimerMode.normal);
      expect(actualSettings.isSoundEnabled, isTrue);
      expect(actualSettings.isVibrationEnabled, isTrue);
      expect(actualSettings.isReducedMotionEnabled, isFalse);
      expect(actualSettings.isEverythingUnlocked, isFalse);
    });
    test('copyWith replaces only the given fields', () {
      // Arrange
      const ProfileSettingsEntity inputSettings =
          ProfileSettingsEntity.defaults(profileId: 'profile-1');
      // Act
      final ProfileSettingsEntity actualSettings = inputSettings.copyWith(
        timerMode: TimerMode.off,
        dailyGoal: DailyGoal.intense,
      );
      // Assert
      expect(actualSettings.timerMode, TimerMode.off);
      expect(actualSettings.dailyGoal, DailyGoal.intense);
      expect(actualSettings.profileId, inputSettings.profileId);
      expect(actualSettings.isSoundEnabled, inputSettings.isSoundEnabled);
    });
    test('is equal to settings with the same fields', () {
      // Arrange
      const ProfileSettingsEntity inputSettings =
          ProfileSettingsEntity.defaults(profileId: 'profile-1');
      // Act
      final ProfileSettingsEntity actualSettings = inputSettings.copyWith();
      // Assert
      expect(actualSettings, inputSettings);
      expect(actualSettings.hashCode, inputSettings.hashCode);
    });
  });
}
