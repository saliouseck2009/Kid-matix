import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/profile/data/models/profile_local_model.dart';
import 'package:kid_matix/features/profile/data/models/profile_settings_local_model.dart';
import 'package:kid_matix/features/profile/domain/entities/daily_goal.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';

import '../helpers/profile_fixtures.dart';

void main() {
  final DateTime inputUpdatedAt = DateTime(2026, 10, 11);

  group('ProfileLocalModel', () {
    test('stores the normalized nickname and enums by name', () {
      // Arrange
      final ProfileEntity inputProfile = buildProfile(nickname: 'Léa');
      // Act
      final Map<String, Object?> actualRow = ProfileLocalModel.fromEntity(
        profile: inputProfile,
        updatedAt: inputUpdatedAt,
      ).toJson();
      // Assert
      expect(actualRow['normalized_nickname'], 'lea');
      expect(actualRow['avatar'], 'avatar1');
      expect(actualRow['color'], 'violet');
      expect(actualRow['updated_at'], inputUpdatedAt.millisecondsSinceEpoch);
      expect(actualRow['remote_account_id'], isNull);
    });
    test('gives back the same entity, dates included', () {
      // Arrange
      final ProfileEntity expectedProfile = buildProfile().copyWith(
        totalXp: 340,
        level: 3,
        lastPlayedAt: DateTime(2026, 10, 10, 18, 30),
      );
      // Act
      final ProfileEntity actualProfile = ProfileLocalModel.fromJson(
        ProfileLocalModel.fromEntity(
          profile: expectedProfile,
          updatedAt: inputUpdatedAt,
        ).toJson(),
      ).toEntity();
      // Assert
      expect(actualProfile, expectedProfile);
    });
  });

  group('ProfileSettingsLocalModel', () {
    test('stores booleans as 0 or 1 and the goal in XP', () {
      // Arrange
      const ProfileSettingsEntity inputSettings =
          ProfileSettingsEntity.defaults(profileId: 'p-1');
      // Act
      final Map<String, Object?> actualRow =
          ProfileSettingsLocalModel.fromEntity(
            settings: inputSettings,
            updatedAt: inputUpdatedAt,
          ).toJson();
      // Assert
      expect(actualRow['is_sound_enabled'], 1);
      expect(actualRow['is_everything_unlocked'], 0);
      expect(actualRow['daily_goal_xp'], 20);
      expect(actualRow['timer_mode'], 'normal');
    });
    test('gives back the same entity', () {
      // Arrange
      final ProfileSettingsEntity expectedSettings =
          const ProfileSettingsEntity.defaults(profileId: 'p-1').copyWith(
            timerMode: TimerMode.relaxed,
            dailyGoal: DailyGoal.intense,
            isVibrationEnabled: false,
          );
      // Act
      final ProfileSettingsEntity actualSettings =
          ProfileSettingsLocalModel.fromJson(
            ProfileSettingsLocalModel.fromEntity(
              settings: expectedSettings,
              updatedAt: inputUpdatedAt,
            ).toJson(),
          ).toEntity();
      // Assert
      expect(actualSettings, expectedSettings);
    });
    test('falls back to the default goal for an unknown XP value', () {
      // Arrange
      final Map<String, Object?> inputRow =
          ProfileSettingsLocalModel.fromEntity(
            settings: const ProfileSettingsEntity.defaults(profileId: 'p-1'),
            updatedAt: inputUpdatedAt,
          ).toJson()..['daily_goal_xp'] = 35;
      // Act
      final ProfileSettingsEntity actualSettings =
          ProfileSettingsLocalModel.fromJson(inputRow).toEntity();
      // Assert
      expect(actualSettings.dailyGoal, DailyGoal.light);
    });
  });
}
