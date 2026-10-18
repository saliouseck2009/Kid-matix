import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_directory_service.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/features/reward/data/datasources/leaderboard_local_data_source_impl.dart';
import 'package:kid_matix/features/reward/data/datasources/leaderboard_visibility_local_data_source_impl.dart';
import 'package:kid_matix/features/reward/data/repositories/leaderboard_repository_impl.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_scope.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_visibility_repository.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/set_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_leaderboard_visibility_use_case.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/in_memory_local_storage.dart';
import '../../../helpers/test_leaderboard_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

/// Players of the phone, as the profile feature lists them.
final class _FixedPlayers implements PlayerDirectoryService {
  const _FixedPlayers(this.players);

  final DataState<List<PlayerIdentity>> players;

  @override
  Future<DataState<List<PlayerIdentity>>> readPlayers() async => players;
}

/// [LocalStorage] whose every call fails, as a broken plugin would.
final class _FailingStorage implements LocalStorage {
  @override
  Future<String?> readString({required String key}) async {
    throw StateError('no preferences');
  }

  @override
  Future<void> writeString({required String key, required String value}) {
    throw StateError('no preferences');
  }

  @override
  Future<void> remove({required String key}) async {}
}

PlayerIdentity _player(String id, String nickname) {
  return PlayerIdentity(
    id: id,
    nickname: nickname,
    avatarKey: 'avatar1',
    colorKey: 'violet',
  );
}

final List<PlayerIdentity> _players = <PlayerIdentity>[
  _player('p1', 'Awa'),
  _player('p2', 'Moussa'),
  _player('p3', 'Lina'),
];

void main() {
  late AppDatabase appDatabase;
  late Database database;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      resolvePath: () async => inMemoryDatabasePath,
      migrationRunner: MigrationRunner(migrations: appMigrations),
    );
    database = await appDatabase.database;
    for (final PlayerIdentity player in _players) {
      await database.insert('profile', <String, Object?>{
        'id': player.id,
        'nickname': player.nickname,
        'normalized_nickname': player.nickname.toLowerCase(),
        'avatar': player.avatarKey,
        'color': player.colorKey,
        'created_at': 0,
        'updated_at': 0,
      });
    }
  });

  tearDown(() => appDatabase.close());

  Future<void> insertQuizXp(
    String profileId,
    int xp,
    DateTime at, {
    bool isDeleted = false,
  }) async {
    final String sessionId = 'session-${at.millisecondsSinceEpoch}-$xp';
    await database.insert('quiz_session', <String, Object?>{
      'id': sessionId,
      'profile_id': profileId,
      'domain_id': 'multiplication',
      'mode': 'stage',
      'status': 'completed',
      'started_at': at.millisecondsSinceEpoch,
      'duration_ms': 0,
      'question_count': 10,
      'correct_count': 10,
      'updated_at': 0,
    });
    await database.insert('session_reward', <String, Object?>{
      'session_id': sessionId,
      'profile_id': profileId,
      'xp_earned': xp,
      'xp_version': 1,
      'earned_at': at.millisecondsSinceEpoch,
      'updated_at': 0,
      'deleted_at': isDeleted ? 0 : null,
    });
  }

  Future<void> insertDuelXp(String profileId, int xp, DateTime at) {
    return database.insert('xp_award', <String, Object?>{
      'id': 'award-${at.millisecondsSinceEpoch}-$xp',
      'profile_id': profileId,
      'source_key': 'duel',
      'xp_earned': xp,
      'earned_at': at.millisecondsSinceEpoch,
      'updated_at': 0,
    });
  }

  GetLeaderboardUseCase buildUseCase(FakeClock clock) {
    return GetLeaderboardUseCase(
      repository: LeaderboardRepositoryImpl(
        local: LeaderboardLocalDataSourceImpl(database: appDatabase),
        players: _FixedPlayers(DataSuccess<List<PlayerIdentity>>(_players)),
      ),
      clock: clock,
    );
  }

  Map<String, int> xpOf(LeaderboardEntity board) {
    return <String, int>{
      for (final LeaderboardEntry entry in board.entries)
        entry.player.nickname: entry.weeklyXp,
    };
  }

  group('Weekly leaderboard over the database', () {
    test('sums quiz and duel XP of the week, every player shown', () async {
      // Arrange
      await insertQuizXp('p1', 100, DateTime(2026, 10, 12, 9));
      await insertDuelXp('p1', 120, DateTime(2026, 10, 13, 18));
      await insertQuizXp('p2', 200, DateTime(2026, 10, 14, 17));
      await insertQuizXp('p2', 500, DateTime(2026, 10, 11, 20));
      await insertQuizXp('p2', 300, DateTime(2026, 10, 15, 8), isDeleted: true);
      // Act
      final LeaderboardEntity actualBoard = (await buildUseCase(
        FakeClock(DateTime(2026, 10, 15, 17)),
      )(params: LeaderboardScope.phone)).requireData;
      // Assert
      expect(
        actualBoard.entries.map((LeaderboardEntry e) => e.player.nickname),
        <String>['Awa', 'Moussa', 'Lina'],
      );
      expect(xpOf(actualBoard), <String, int>{
        'Awa': 220,
        'Moussa': 200,
        'Lina': 0,
      });
    });
    test('starts again from zero when Sunday turns into Monday', () async {
      // Arrange
      await insertQuizXp('p1', 90, DateTime(2026, 10, 18, 23, 30));
      await insertDuelXp('p2', 40, DateTime(2026, 10, 18, 23, 59));
      final FakeClock inputClock = FakeClock(
        DateTime(2026, 10, 18, 23, 59, 59),
      );
      final GetLeaderboardUseCase inputUseCase = buildUseCase(inputClock);
      // Act
      final LeaderboardEntity actualSunday = (await inputUseCase(
        params: LeaderboardScope.phone,
      )).requireData;
      inputClock.now_ = DateTime(2026, 10, 19);
      await insertDuelXp('p3', 20, DateTime(2026, 10, 19));
      final LeaderboardEntity actualMonday = (await inputUseCase(
        params: LeaderboardScope.phone,
      )).requireData;
      // Assert
      expect(xpOf(actualSunday), <String, int>{
        'Awa': 90,
        'Moussa': 40,
        'Lina': 0,
      });
      expect(xpOf(actualMonday), <String, int>{
        'Lina': 20,
        'Awa': 0,
        'Moussa': 0,
      });
    });
    test('fails for the online scopes', () async {
      // Act
      final List<DataState<LeaderboardEntity>> actualReads =
          <DataState<LeaderboardEntity>>[
            await buildUseCase(
              FakeClock(quizStart),
            )(params: LeaderboardScope.friends),
            await buildUseCase(
              FakeClock(quizStart),
            )(params: LeaderboardScope.world),
          ];
      // Assert
      expect(
        actualReads.map((DataState<LeaderboardEntity> read) {
          return read.exceptionOrNull;
        }),
        everyElement(isA<UnknownException>()),
      );
    });
    test('passes a failure of the players through', () async {
      // Arrange
      final LeaderboardRepositoryImpl inputRepository =
          LeaderboardRepositoryImpl(
            local: LeaderboardLocalDataSourceImpl(database: appDatabase),
            players: const _FixedPlayers(
              DataFailed<List<PlayerIdentity>>(NotFoundException()),
            ),
          );
      // Act
      final DataState<List<LeaderboardEntry>> actualRead = await inputRepository
          .getEntries(
            scope: LeaderboardScope.phone,
            from: DateTime(2026, 10, 12),
            to: DateTime(2026, 10, 19),
          );
      // Assert
      expect(actualRead.exceptionOrNull, isA<NotFoundException>());
    });
    test('turns a database failure into a cache failure', () async {
      // Arrange
      await database.execute('DROP TABLE xp_award');
      // Act
      final DataState<LeaderboardEntity> actualRead = await buildUseCase(
        FakeClock(quizStart),
      )(params: LeaderboardScope.phone);
      // Assert
      expect(actualRead.exceptionOrNull, isA<CacheException>());
    });
  });

  group('Leaderboard setting', () {
    test('is shown until changed, then remembered on the device', () async {
      // Arrange
      final InMemoryLocalStorage inputStorage = InMemoryLocalStorage();
      final LeaderboardVisibilityRepository inputRepository =
          buildTestVisibilityRepository(storage: inputStorage);
      final List<bool> actualChanges = <bool>[];
      final Stream<bool> inputChanges = WatchLeaderboardVisibilityUseCase(
        repository: inputRepository,
      )();
      inputChanges.listen(actualChanges.add);
      // Act
      final bool actualDefault = (await GetLeaderboardVisibilityUseCase(
        repository: inputRepository,
      )()).requireData;
      await SetLeaderboardVisibilityUseCase(
        repository: inputRepository,
      )(params: false);
      final bool actualReread = (await GetLeaderboardVisibilityUseCase(
        repository: buildTestVisibilityRepository(storage: inputStorage),
      )()).requireData;
      await Future<void>.delayed(Duration.zero);
      // Assert
      expect(actualDefault, isTrue);
      expect(actualReread, isFalse);
      expect(actualChanges, <bool>[false]);
      expect(
        await inputStorage.readString(
          key: LeaderboardVisibilityLocalDataSourceImpl.leaderboardShownKey,
        ),
        'false',
      );
    });
    test('reads a value shown again', () async {
      // Arrange
      final LeaderboardVisibilityRepository inputRepository =
          buildTestVisibilityRepository();
      await inputRepository.setShown(isShown: false);
      // Act
      await inputRepository.setShown(isShown: true);
      // Assert
      expect((await inputRepository.isShown()).requireData, isTrue);
    });
    test('fails as a cache failure when the preferences fail', () async {
      // Arrange
      final LeaderboardVisibilityRepository inputRepository =
          buildTestVisibilityRepository(storage: _FailingStorage());
      final List<bool> actualChanges = <bool>[];
      inputRepository.watchShown().listen(actualChanges.add);
      // Act
      final DataState<bool> actualRead = await inputRepository.isShown();
      final DataState<void> actualSaved = await inputRepository.setShown(
        isShown: false,
      );
      await Future<void>.delayed(Duration.zero);
      // Assert
      expect(actualRead.exceptionOrNull, isA<CacheException>());
      expect(actualSaved.exceptionOrNull, isA<CacheException>());
      expect(actualChanges, isEmpty);
    });
  });
}
