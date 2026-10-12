import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_local_data_source_impl.dart';
import 'package:kid_matix/features/reward/data/models/xp_award_local_model.dart';
import 'package:kid_matix/features/reward/data/repositories/reward_repository_impl.dart';
import 'package:kid_matix/features/reward/data/repositories/reward_reset_hook.dart';
import 'package:kid_matix/features/reward/domain/entities/daily_goal_progress.dart';
import 'package:kid_matix/features/reward/domain/entities/player_level.dart';
import 'package:kid_matix/features/reward/domain/entities/xp_award_entity.dart';
import 'package:kid_matix/features/reward/domain/services/xp_award_service_impl.dart';
import 'package:kid_matix/features/reward/domain/usecases/award_xp_params.dart';
import 'package:kid_matix/features/reward/domain/usecases/award_xp_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_daily_goal_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_player_level_use_case.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

/// Monday 12 October 2026 at 17:00.
final DateTime _now = DateTime(2026, 10, 12, 17);

void main() {
  late AppDatabase appDatabase;
  late TableChangeBus changeBus;
  late RewardRepositoryImpl rewards;
  late AwardXpUseCase awardXp;
  final FakeClock clock = FakeClock(_now);

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
    rewards = RewardRepositoryImpl(
      rewards: RewardLocalDataSourceImpl(database: appDatabase),
      changeBus: changeBus,
    );
    awardXp = AwardXpUseCase(
      repository: rewards,
      ids: const FixedIdGenerator('award-1'),
      clock: clock,
    );
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  group('XP awards', () {
    test('count in the total, the level and the daily goal', () async {
      // Arrange
      final XpAwardServiceImpl inputService = XpAwardServiceImpl(
        awardXp: awardXp,
      );
      // Act
      final DataState<void> actualSaved = await inputService.awardXp(
        profileId: 'p1',
        xp: 120,
        sourceKey: 'duel',
      );
      // Assert
      expect(actualSaved, isA<DataSuccess<void>>());
      final PlayerLevel actualLevel = (await GetPlayerLevelUseCase(
        repository: rewards,
      )(params: 'p1')).requireData;
      final DailyGoalProgress actualGoal = (await GetDailyGoalUseCase(
        repository: rewards,
        settings: const FixedPlayerSettings(),
        clock: clock,
      )(params: 'p1')).requireData;
      expect(actualLevel.level, 2);
      expect(actualGoal.earnedXp, 120);
      final Map<String, Object?> actualProfile =
          (await (await appDatabase.database).query('profile')).single;
      expect(actualProfile['total_xp'], 120);
      expect(actualProfile['level'], 2);
      final Map<String, Object?> actualRow =
          (await (await appDatabase.database).query('xp_award')).single;
      expect(actualRow['source_key'], 'duel');
      expect(
        XpAwardLocalModel.fromJson(actualRow).toEntity(),
        XpAwardEntity(
          id: 'award-1',
          profileId: 'p1',
          sourceKey: 'duel',
          xp: 120,
          earnedAt: _now,
        ),
      );
    });
    test('add up with the XP already earned', () async {
      // Arrange
      await awardXp(
        params: const AwardXpParams(profileId: 'p1', xp: 80, sourceKey: 'a'),
      );
      // Act
      await AwardXpUseCase(
        repository: rewards,
        ids: const FixedIdGenerator('award-2'),
        clock: clock,
      )(
        params: const AwardXpParams(profileId: 'p1', xp: 40, sourceKey: 'b'),
      );
      // Assert
      expect((await rewards.getXpEarned(profileId: 'p1')).requireData, 120);
      expect(
        (await rewards.getXpEarned(
          profileId: 'p1',
          from: _now.add(const Duration(seconds: 1)),
        )).requireData,
        0,
      );
    });
    test('save nothing for no XP', () async {
      // Act
      final DataState<void> actualSaved = await awardXp(
        params: const AwardXpParams(profileId: 'p1', xp: 0, sourceKey: 'a'),
      );
      // Assert
      expect(actualSaved, isA<DataSuccess<void>>());
      expect(await (await appDatabase.database).query('xp_award'), isEmpty);
    });
    test('tell the watchers', () async {
      // Arrange
      final Future<void> actualChange = rewards.watchChanges().first;
      // Act
      await awardXp(
        params: const AwardXpParams(profileId: 'p1', xp: 10, sourceKey: 'a'),
      );
      // Assert
      await expectLater(actualChange, completes);
    });
    test('fail once the database is closed', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final AppException? actualException = (await awardXp(
        params: const AwardXpParams(profileId: 'p1', xp: 10, sourceKey: 'a'),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
    test('are erased with the progress', () async {
      // Arrange
      await awardXp(
        params: const AwardXpParams(profileId: 'p1', xp: 30, sourceKey: 'a'),
      );
      final Database database = await appDatabase.database;
      // Act
      final List<String> actualTables = await database.transaction(
        (Transaction transaction) =>
            const RewardResetHook().reset(transaction, profileId: 'p1'),
      );
      // Assert
      expect(actualTables, contains('xp_award'));
      expect(await database.query('xp_award'), isEmpty);
      expect((await rewards.getXpEarned(profileId: 'p1')).requireData, 0);
    });
    test('compare by value', () {
      // Arrange
      final XpAwardEntity inputAward = XpAwardEntity(
        id: 'a',
        profileId: 'p1',
        sourceKey: 'duel',
        xp: 10,
        earnedAt: _now,
      );
      // Act
      final XpAwardEntity actualCopy = inputAward.copyWith(xp: 20);
      // Assert
      expect(actualCopy, isNot(inputAward));
      expect(actualCopy.copyWith(xp: 10), inputAward);
      expect(actualCopy.copyWith(xp: 10).hashCode, inputAward.hashCode);
      expect(
        const AwardXpParams(profileId: 'p', xp: 1, sourceKey: 's'),
        const AwardXpParams(profileId: 'p', xp: 1, sourceKey: 's'),
      );
      expect(
        const AwardXpParams(profileId: 'p', xp: 1, sourceKey: 's').hashCode,
        const AwardXpParams(profileId: 'p', xp: 1, sourceKey: 's').hashCode,
      );
    });
  });
}
