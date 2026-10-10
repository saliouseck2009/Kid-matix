import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/challenge/data/datasources/record_local_data_source_impl.dart';
import 'package:kid_matix/features/challenge/data/repositories/record_repository_impl.dart';
import 'package:kid_matix/features/challenge/data/repositories/record_session_hook.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_records_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_session_record_use_case.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';

final class _Clock implements Clock {
  @override
  DateTime now() => DateTime(2026, 10, 10, 18);
}

Future<AppDatabase> _open(int version, String path) async {
  return AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => path,
    migrationRunner: MigrationRunner(
      migrations: appMigrations.take(version).toList(),
    ),
  );
}

const Map<String, Object?> _profileRow = <String, Object?>{
  'id': 'p1',
  'nickname': 'Awa',
  'normalized_nickname': 'awa',
  'avatar': 'avatar1',
  'color': 'violet',
  'created_at': 0,
  'updated_at': 0,
};

SavedQuizSession _session({
  required String id,
  required int correctCount,
  QuizMode mode = QuizMode.timeAttack,
  bool isCompleted = true,
}) {
  return SavedQuizSession(
    id: id,
    profileId: 'p1',
    domainId: 'multiplication',
    mode: mode,
    isCompleted: isCompleted,
    questionCount: correctCount + 2,
    correctCount: correctCount,
    endedAt: DateTime(2026, 10, 10, 17),
    sourceKey: 'timeAttack:mul:1',
  );
}

void main() {
  late AppDatabase appDatabase;
  late TableChangeBus changeBus;
  late RecordSessionHook hook;
  late RecordRepositoryImpl repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = await _open(appMigrations.length, inMemoryDatabasePath);
    await (await appDatabase.database).insert('profile', _profileRow);
    final RecordLocalDataSourceImpl dataSource = RecordLocalDataSourceImpl(
      database: appDatabase,
    );
    changeBus = TableChangeBus();
    hook = RecordSessionHook(records: dataSource, clock: _Clock());
    repository = RecordRepositoryImpl(
      records: dataSource,
      changeBus: changeBus,
    );
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  Future<List<String>> save(SavedQuizSession session) async {
    final SessionWrite write = await hook.prepare(session: session);
    return (await appDatabase.database).transaction(write);
  }

  Future<Map<QuizMode, RecordEntity>> readRecords() async {
    return (await GetRecordsUseCase(
      repository: repository,
    )(params: 'p1')).requireData;
  }

  group('RecordSessionHook', () {
    test('stores the first time attack as the record', () async {
      // Act
      final List<String> actualTables = await save(
        _session(id: 's1', correctCount: 15),
      );
      // Assert
      final RecordEntity actualRecord =
          (await readRecords())[QuizMode.timeAttack]!;
      expect(actualTables, <String>['record']);
      expect(actualRecord.bestScore, 15);
      expect(actualRecord.sessionId, 's1');
      expect(actualRecord.previousBest, isNull);
      expect(actualRecord.achievedAt, DateTime(2026, 10, 10, 17));
    });
    test('replaces the record only when it is beaten', () async {
      // Arrange
      await save(_session(id: 's1', correctCount: 15));
      // Act
      final List<String> actualLower = await save(
        _session(id: 's2', correctCount: 12),
      );
      await save(_session(id: 's3', correctCount: 18));
      // Assert
      final RecordEntity actualRecord =
          (await readRecords())[QuizMode.timeAttack]!;
      expect(actualLower, isEmpty);
      expect(actualRecord.bestScore, 18);
      expect(actualRecord.sessionId, 's3');
      expect(actualRecord.previousBest, 15);
    });
    test('ignores an abandoned quiz and a free training', () async {
      // Act
      await save(_session(id: 's1', correctCount: 15, isCompleted: false));
      await save(
        _session(id: 's2', correctCount: 15, mode: QuizMode.freeTraining),
      );
      // Assert
      expect(await readRecords(), isEmpty);
    });
  });

  group('GetSessionRecordUseCase', () {
    test('finds the record a session set, and none for another', () async {
      // Arrange
      await save(_session(id: 's1', correctCount: 15));
      await save(_session(id: 's2', correctCount: 9));
      final GetSessionRecordUseCase useCase = GetSessionRecordUseCase(
        repository: repository,
      );
      // Act
      final RecordEntity? actualSet = (await useCase(
        params: 's1',
      )).requireData;
      final RecordEntity? actualNone = (await useCase(
        params: 's2',
      )).requireData;
      // Assert
      expect(actualSet?.bestScore, 15);
      expect(actualNone, isNull);
    });
  });

  group('RecordRepositoryImpl', () {
    test('fails to read once the database is closed', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final AppException? actualException = (await repository.getRecords(
        profileId: 'p1',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  test('Migration 9 upgrades a version 8 database', () async {
    // Arrange
    final String inputPath =
        '${await databaseFactoryFfi.getDatabasesPath()}'
        '/migration_009_upgrade_test.db';
    await databaseFactoryFfi.deleteDatabase(inputPath);
    final AppDatabase versionEight = await _open(8, inputPath);
    await (await versionEight.database).insert('profile', _profileRow);
    await versionEight.close();
    // Act
    final AppDatabase versionNine = await _open(9, inputPath);
    final Database upgraded = await versionNine.database;
    // Assert
    expect(await upgraded.getVersion(), 9);
    expect(await upgraded.query('profile'), hasLength(1));
    expect(await upgraded.query('record'), isEmpty);
    await versionNine.close();
    await databaseFactoryFfi.deleteDatabase(inputPath);
  });
}
