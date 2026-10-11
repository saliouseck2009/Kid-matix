import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/daily_goal_progress.dart';
import 'package:kid_matix/features/reward/domain/entities/player_level.dart';
import 'package:kid_matix/features/reward/domain/entities/session_rewards_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_summary.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:kid_matix/features/reward/domain/services/reward_service_impl.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_badges_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_daily_goal_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_player_level_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_session_rewards_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_streak_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_reward_changes_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

final class _MockRewardRepository extends Mock implements RewardRepository {}

final class _MockPlayerSettingsService extends Mock
    implements PlayerSettingsService {}

const CacheException _failure = CacheException(message: 'disk error');

final SessionXp _sessionXp = (
  profileId: 'p1',
  xp: 40,
  earnedAt: DateTime(2026, 10, 10, 17),
);

void main() {
  late _MockRewardRepository mockRepository;

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() => mockRepository = _MockRewardRepository());

  void stubXpEarned(DataState<int> state) {
    when(
      () => mockRepository.getXpEarned(
        profileId: any(named: 'profileId'),
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => state);
  }

  void stubBadges(DataState<List<BadgeUnlockEntity>> state) {
    when(
      () => mockRepository.getBadges(profileId: any(named: 'profileId')),
    ).thenAnswer((_) async => state);
  }

  void stubStreak(DataState<StreakEntity> state) {
    when(
      () => mockRepository.getStreak(profileId: any(named: 'profileId')),
    ).thenAnswer((_) async => state);
  }

  void stubSessionXp(DataState<SessionXp?> state) {
    when(
      () => mockRepository.getSessionXp(sessionId: any(named: 'sessionId')),
    ).thenAnswer((_) async => state);
  }

  RewardServiceImpl buildService() {
    return RewardServiceImpl(
      getLevel: GetPlayerLevelUseCase(repository: mockRepository),
      getBadges: GetBadgesUseCase(repository: mockRepository),
      getStreak: GetStreakUseCase(
        repository: mockRepository,
        clock: FakeClock(DateTime(2026, 10, 10, 18)),
      ),
      watchChanges: WatchRewardChangesUseCase(repository: mockRepository),
    );
  }

  group('RewardServiceImpl', () {
    test('passes on the failure of every read', () async {
      // Arrange
      stubXpEarned(const DataFailed<int>(_failure));
      stubBadges(const DataFailed<List<BadgeUnlockEntity>>(_failure));
      stubStreak(const DataFailed<StreakEntity>(_failure));
      final RewardServiceImpl service = buildService();
      // Act
      final DataState<int> actualLevel = await service.readLevel(
        profileId: 'p1',
      );
      final DataState<int> actualStreak = await service.readStreak(
        profileId: 'p1',
      );
      final DataState<Set<String>> actualBadges = await service.readBadgeKeys(
        profileId: 'p1',
      );
      // Assert
      expect(actualLevel.exceptionOrNull, _failure);
      expect(actualStreak.exceptionOrNull, _failure);
      expect(actualBadges.exceptionOrNull, _failure);
    });

    test('forwards the changes of the repository', () async {
      // Arrange
      when(
        () => mockRepository.watchChanges(),
      ).thenAnswer((_) => Stream<void>.value(null));
      final RewardServiceImpl service = buildService();
      // Act
      final List<void> actualEvents = await service.watchChanges().toList();
      // Assert
      expect(actualEvents, hasLength(1));
    });
  });

  group('GetStreakUseCase', () {
    test('passes on a failure of the repository', () async {
      // Arrange
      stubStreak(const DataFailed<StreakEntity>(_failure));
      final GetStreakUseCase useCase = GetStreakUseCase(
        repository: mockRepository,
        clock: FakeClock(DateTime(2026, 10, 10)),
      );
      // Act
      final DataState<StreakSummary> actualState = await useCase(
        params: 'p1',
      );
      // Assert
      expect(actualState.exceptionOrNull, _failure);
    });
  });

  group('GetDailyGoalUseCase', () {
    test('passes on a failure to read the XP of the day', () async {
      // Arrange
      final _MockPlayerSettingsService mockSettings =
          _MockPlayerSettingsService();
      when(
        () => mockSettings.readDailyGoalXp(profileId: any(named: 'profileId')),
      ).thenAnswer((_) async => const DataSuccess<int>(50));
      stubXpEarned(const DataFailed<int>(_failure));
      final GetDailyGoalUseCase useCase = GetDailyGoalUseCase(
        repository: mockRepository,
        settings: mockSettings,
        clock: FakeClock(DateTime(2026, 10, 10, 9)),
      );
      // Act
      final DataState<DailyGoalProgress> actualState = await useCase(
        params: 'p1',
      );
      // Assert
      expect(actualState.exceptionOrNull, _failure);
    });
  });

  group('GetSessionRewardsUseCase', () {
    late GetSessionRewardsUseCase useCase;

    setUp(
      () => useCase = GetSessionRewardsUseCase(repository: mockRepository),
    );

    test('passes on a failure to read the session XP', () async {
      // Arrange
      stubSessionXp(const DataFailed<SessionXp?>(_failure));
      // Act
      final DataState<SessionRewardsEntity?> actualState = await useCase(
        params: 's1',
      );
      // Assert
      expect(actualState.exceptionOrNull, _failure);
    });

    test('passes on a failure to read the total XP', () async {
      // Arrange
      stubSessionXp(DataSuccess<SessionXp?>(_sessionXp));
      stubXpEarned(const DataFailed<int>(_failure));
      stubBadges(
        const DataSuccess<List<BadgeUnlockEntity>>(<BadgeUnlockEntity>[]),
      );
      // Act
      final DataState<SessionRewardsEntity?> actualState = await useCase(
        params: 's1',
      );
      // Assert
      expect(actualState.exceptionOrNull, _failure);
    });

    test('passes on a failure to read the badges', () async {
      // Arrange
      stubSessionXp(DataSuccess<SessionXp?>(_sessionXp));
      stubXpEarned(const DataSuccess<int>(400));
      stubBadges(const DataFailed<List<BadgeUnlockEntity>>(_failure));
      // Act
      final DataState<SessionRewardsEntity?> actualState = await useCase(
        params: 's1',
      );
      // Assert
      expect(actualState.exceptionOrNull, _failure);
    });

    test('keeps only the badges of the session', () async {
      // Arrange
      stubSessionXp(DataSuccess<SessionXp?>(_sessionXp));
      stubXpEarned(const DataSuccess<int>(400));
      stubBadges(
        DataSuccess<List<BadgeUnlockEntity>>(<BadgeUnlockEntity>[
          BadgeUnlockEntity(
            badgeKey: 'first_quiz',
            unlockedAt: DateTime(2026),
            sessionId: 's0',
          ),
          BadgeUnlockEntity(
            badgeKey: 'perfect',
            unlockedAt: DateTime(2026),
            sessionId: 's1',
          ),
        ]),
      );
      // Act
      final SessionRewardsEntity? actualRewards = (await useCase(
        params: 's1',
      )).requireData;
      // Assert
      expect(actualRewards?.xpEarned, 40);
      expect(actualRewards?.newBadges, <String>['perfect']);
    });
  });

  group('GetPlayerLevelUseCase', () {
    test('passes on a failure of the repository', () async {
      // Arrange
      stubXpEarned(const DataFailed<int>(_failure));
      final GetPlayerLevelUseCase useCase = GetPlayerLevelUseCase(
        repository: mockRepository,
      );
      // Act
      final DataState<PlayerLevel> actualState = await useCase(params: 'p1');
      // Assert
      expect(actualState.exceptionOrNull, _failure);
    });
  });
}
