import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/daily_goal.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/services/player_settings_service_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/data_state_test_extension.dart';
import '../../helpers/profile_fixtures.dart';

void main() {
  late MockProfileRepository mockRepository;
  late PlayerSettingsServiceImpl service;

  setUp(() {
    mockRepository = MockProfileRepository();
    service = PlayerSettingsServiceImpl(repository: mockRepository);
  });

  group('PlayerSettingsServiceImpl', () {
    test("reads the player's timer mode", () async {
      // Arrange
      when(
        () => mockRepository.getProfileSettings(
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer(
        (_) async => DataSuccess<ProfileSettingsEntity>(
          const ProfileSettingsEntity.defaults(
            profileId: 'p-1',
          ).copyWith(timerMode: TimerMode.relaxed),
        ),
      );
      // Act
      final TimerMode actualMode = (await service.readTimerMode(
        profileId: 'p-1',
      )).requireData;
      // Assert
      expect(actualMode, TimerMode.relaxed);
      verify(() => mockRepository.getProfileSettings(profileId: 'p-1'))
          .called(1);
    });
    test('reads whether everything is unlocked', () async {
      // Arrange
      when(
        () => mockRepository.getProfileSettings(
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer(
        (_) async => DataSuccess<ProfileSettingsEntity>(
          const ProfileSettingsEntity.defaults(
            profileId: 'p-1',
          ).copyWith(isEverythingUnlocked: true),
        ),
      );
      // Act
      final bool actualUnlocked = (await service.readEverythingUnlocked(
        profileId: 'p-1',
      )).requireData;
      // Assert
      expect(actualUnlocked, isTrue);
    });
    test('reads the daily goal of the player', () async {
      // Arrange
      when(
        () => mockRepository.getProfileSettings(
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer(
        (_) async => DataSuccess<ProfileSettingsEntity>(
          const ProfileSettingsEntity.defaults(
            profileId: 'p-1',
          ).copyWith(dailyGoal: DailyGoal.intense),
        ),
      );
      // Act
      final int actualGoal = (await service.readDailyGoalXp(
        profileId: 'p-1',
      )).requireData;
      // Assert
      expect(actualGoal, 100);
    });
    test('forwards a failure to read the settings', () async {
      // Arrange
      when(
        () => mockRepository.getProfileSettings(
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer(
        (_) async =>
            const DataFailed<ProfileSettingsEntity>(NotFoundException()),
      );
      // Act
      final AppException? actualException = (await service.readTimerMode(
        profileId: 'p-1',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<NotFoundException>());
    });
  });
}
