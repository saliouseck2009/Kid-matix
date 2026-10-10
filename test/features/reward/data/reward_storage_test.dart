import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_service_impl.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_session_local_data_source_impl.dart';
import 'package:kid_matix/features/quiz/data/repositories/quiz_session_repository_impl.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_local_data_source_impl.dart';
import 'package:kid_matix/features/reward/data/repositories/reward_repository_impl.dart';
import 'package:kid_matix/features/reward/data/repositories/reward_session_hook.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_key.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/daily_goal_progress.dart';
import 'package:kid_matix/features/reward/domain/entities/player_level.dart';
import 'package:kid_matix/features/reward/domain/entities/session_rewards_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_summary.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_badges_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_daily_goal_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_player_level_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_session_rewards_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_streak_use_case.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

final class _Clock implements Clock {
  _Clock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}

/// Saturday 10 October 2026 at 17:00.
final DateTime _start = DateTime(2026, 10, 10, 17);

QuizSessionEntity _session(
  String id, {
  int correct = 10,
  QuizSessionStatus status = QuizSessionStatus.completed,
  String? sourceKey = 'path:mul:1:discovery',
  DateTime? startedAt,
  BossOutcome? bossOutcome,
}) {
  return QuizSessionEntity(
    id: id,
    profileId: 'p1',
    domainId: 'multiplication',
    mode: QuizMode.path,
    status: status,
    startedAt: startedAt ?? _start,
    duration: const Duration(minutes: 1),
    questionCount: 10,
    correctCount: correct,
    sourceKey: sourceKey,
    bossOutcome: bossOutcome,
  );
}

List<QuizAnswerEntity> _answers({int lightning = 2}) {
  return <QuizAnswerEntity>[
    for (int index = 0; index < 10; index++)
      QuizAnswerEntity(
        itemKey: 'mul:1x${index + 1}',
        questionTypeId: 'multipleChoice',
        isCorrect: true,
        isTimedOut: false,
        isRetry: false,
        answerTime: Duration(seconds: index < lightning ? 1 : 4),
      ),
  ];
}

void main() {
  late AppDatabase appDatabase;
  late TableChangeBus changeBus;
  late _Clock clock;
  late QuizSessionRepositoryImpl sessions;
  late RewardRepositoryImpl rewards;
  late FakeMasteryService mastery;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      resolvePath: () async => inMemoryDatabasePath,
      migrationRunner: MigrationRunner(migrations: appMigrations),
    );
    await (await appDatabase.database).insert('profile', <String, Object?>{
      'id': 'p1',
      'nickname': 'Awa',
      'normalized_nickname': 'awa',
      'avatar': 'avatar1',
      'color': 'violet',
      'created_at': 0,
      'updated_at': 0,
    });
    changeBus = TableChangeBus();
    clock = _Clock(_start.add(const Duration(minutes: 1)));
    mastery = FakeMasteryService();
    final RewardLocalDataSourceImpl rewardData = RewardLocalDataSourceImpl(
      database: appDatabase,
    );
    final SessionSavedHooks hooks = SessionSavedHooks()
      ..add(
        RewardSessionHook(
          rewards: rewardData,
          mastery: mastery,
          learningPath: const LearningPathServiceImpl(),
          domains: buildDomainRegistry(),
          clock: clock,
        ),
      );
    sessions = QuizSessionRepositoryImpl(
      sessions: QuizSessionLocalDataSourceImpl(
        database: appDatabase,
        hooks: hooks,
      ),
      clock: clock,
      changeBus: changeBus,
    );
    rewards = RewardRepositoryImpl(rewards: rewardData, changeBus: changeBus);
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  Future<void> save(QuizSessionEntity session, {int lightning = 2}) async {
    (await sessions.saveSession(
      session: session,
      answers: _answers(lightning: lightning),
    )).requireData;
  }

  group('RewardSessionHook', () {
    test('rewards a first perfect stage', () async {
      // Act
      await save(_session('s1'));
      // Assert
      final SessionRewardsEntity actualRewards =
          (await GetSessionRewardsUseCase(repository: rewards)(
            params: 's1',
          )).requireData!;
      expect(actualRewards.xpEarned, 100 + 10 + 20 + 50);
      expect(actualRewards.levelBefore.level, 1);
      expect(actualRewards.levelAfter.level, 2);
      expect(actualRewards.isLevelUp, isTrue);
      expect(actualRewards.newBadges, <String>[
        BadgeKey.firstStep,
        BadgeKey.perfect,
      ]);
      final Map<String, Object?> actualProfile =
          (await (await appDatabase.database).query('profile')).single;
      expect(actualProfile['total_xp'], 180);
      expect(actualProfile['level'], 2);
    });
    test('gives nothing to an abandoned quiz', () async {
      // Act
      await save(_session('s1', status: QuizSessionStatus.abandoned));
      // Assert
      final SessionRewardsEntity? actualRewards =
          (await GetSessionRewardsUseCase(repository: rewards)(
            params: 's1',
          )).requireData;
      expect(actualRewards, isNull);
      expect(
        (await GetStreakUseCase(repository: rewards, clock: clock)(
          params: 'p1',
        )).requireData.current,
        0,
      );
    });
    test('grows the streak day after day and keeps the badges', () async {
      // Arrange
      await save(_session('s1'));
      // Act
      await save(
        _session('s2', startedAt: _start.add(const Duration(days: 1))),
      );
      clock.current = _start.add(const Duration(days: 1, hours: 1));
      // Assert
      final StreakSummary actualStreak = (await GetStreakUseCase(
        repository: rewards,
        clock: clock,
      )(params: 'p1')).requireData;
      final List<BadgeUnlockEntity> actualBadges = (await GetBadgesUseCase(
        repository: rewards,
      )(params: 'p1')).requireData;
      expect(actualStreak.current, 2);
      expect(actualStreak.best, 2);
      expect(actualStreak.isJokerAvailable, isTrue);
      expect(actualBadges, hasLength(2));
    });
    test('crowns a table with its tamer badge', () async {
      // Act
      await save(
        _session(
          's1',
          sourceKey: 'path:mul:1:boss',
          bossOutcome: BossOutcome.defeated,
        ),
      );
      // Assert
      final List<String> actualBadges =
          (await GetBadgesUseCase(
                repository: rewards,
              )(params: 'p1')).requireData
              .map((BadgeUnlockEntity badge) => badge.badgeKey)
              .toList();
      expect(actualBadges, contains('tamer:mul:1'));
    });
    test('counts the lightning answers across quizzes', () async {
      // Act
      await save(_session('s1', sourceKey: null), lightning: 10);
      await save(_session('s2', sourceKey: null), lightning: 10);
      // Assert
      final List<String> actualBadges =
          (await GetBadgesUseCase(
                repository: rewards,
              )(params: 'p1')).requireData
              .map((BadgeUnlockEntity badge) => badge.badgeKey)
              .toList();
      expect(actualBadges, <String>[BadgeKey.lightning]);
    });
    test('unlocks Les 120 once every fact is mastered', () async {
      // Arrange
      mastery.masteredItems.addAll(<String>{
        for (int table = 1; table <= 12; table++)
          for (int multiplier = 1; multiplier <= 10; multiplier++)
            'mul:${table}x$multiplier',
      });
      // Act
      await save(_session('s1', sourceKey: null));
      // Assert
      final List<BadgeUnlockEntity> actualBadges = (await GetBadgesUseCase(
        repository: rewards,
      )(params: 'p1')).requireData;
      expect(actualBadges.single.badgeKey, BadgeKey.allFacts);
    });
  });

  group('reward reads', () {
    test('sums the XP of today against the daily goal', () async {
      // Arrange
      await save(
        _session('s1', startedAt: _start.subtract(const Duration(days: 1))),
      );
      await save(_session('s2', correct: 5));
      // Act
      final DailyGoalProgress actualGoal = (await GetDailyGoalUseCase(
        repository: rewards,
        settings: const FixedPlayerSettings(),
        clock: clock,
      )(params: 'p1')).requireData;
      final PlayerLevel actualLevel = (await GetPlayerLevelUseCase(
        repository: rewards,
      )(params: 'p1')).requireData;
      // Assert
      expect(actualGoal.earnedXp, 50 + 10 + 20);
      expect(actualGoal.goalXp, 20);
      expect(actualGoal.isReached, isTrue);
      expect(actualLevel.level, 2);
    });
    test('fails once the database is closed', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final AppException? actualException = (await rewards.getStreak(
        profileId: 'p1',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
    test('tells when the rewards change', () async {
      // Arrange
      final Future<void> actualChange = rewards.watchChanges().first;
      // Act
      await save(_session('s1'));
      // Assert
      await expectLater(actualChange, completes);
    });
  });

  test('a settings failure fails the daily goal', () async {
    // Act
    final AppException? actualException = (await GetDailyGoalUseCase(
      repository: rewards,
      settings: _BrokenSettings(),
      clock: clock,
    )(params: 'p1')).exceptionOrNull;
    // Assert
    expect(actualException, isA<CacheException>());
  });
}

final class _BrokenSettings extends Mock implements PlayerSettingsService {
  @override
  Future<DataState<int>> readDailyGoalXp({required String profileId}) async =>
      const DataFailed<int>(CacheException());
}
