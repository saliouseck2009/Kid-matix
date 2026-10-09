import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/migrations/migration_001_create_profile_tables.dart';
import 'package:kid_matix/core/storage/migrations/migration_002_create_quiz_session_tables.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const Map<String, Object?> _profileRow = <String, Object?>{
  'id': 'p1',
  'nickname': 'Awa',
  'normalized_nickname': 'awa',
  'avatar': 'avatar1',
  'color': 'violet',
  'created_at': 0,
  'updated_at': 0,
};

const Map<String, Object?> _sessionRow = <String, Object?>{
  'id': 's1',
  'profile_id': 'p1',
  'domain_id': 'multiplication',
  'mode': 'freeTraining',
  'status': 'completed',
  'started_at': 0,
  'duration_ms': 60000,
  'question_count': 10,
  'correct_count': 9,
  'updated_at': 0,
};

Map<String, Object?> _answerRow(int position) => <String, Object?>{
  'session_id': 's1',
  'position': position,
  'item_key': 'mul:5x$position',
  'question_type_id': 'typedAnswer',
  'is_correct': 1,
  'is_timed_out': 0,
  'is_retry': 0,
  'answer_time_ms': 2400,
  'updated_at': 0,
};

AppDatabase _openDatabase(List<DatabaseMigration> migrations, String path) {
  return AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => path,
    migrationRunner: MigrationRunner(migrations: migrations),
  );
}

Future<int> _count(Database database, String table) async {
  final List<Map<String, Object?>> rows = await database.rawQuery(
    'SELECT COUNT(*) AS n FROM $table',
  );
  return rows.single['n']! as int;
}

void main() {
  late AppDatabase appDatabase;
  late Database database;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = _openDatabase(const <DatabaseMigration>[
      Migration001CreateProfileTables(),
      Migration002CreateQuizSessionTables(),
    ], inMemoryDatabasePath);
    database = await appDatabase.database;
    await database.insert('profile', _profileRow);
  });

  tearDown(() => appDatabase.close());

  group('Migration 2', () {
    test('stores a session and its answers', () async {
      // Act
      await database.insert('quiz_session', _sessionRow);
      await database.insert('quiz_answer', _answerRow(1));
      await database.insert('quiz_answer', _answerRow(2));
      // Assert
      expect(await _count(database, 'quiz_session'), 1);
      expect(await _count(database, 'quiz_answer'), 2);
    });
    test('deletes the sessions and answers of a deleted profile', () async {
      // Arrange
      await database.insert('quiz_session', _sessionRow);
      await database.insert('quiz_answer', _answerRow(1));
      // Act
      await database.delete('profile');
      // Assert
      expect(await _count(database, 'quiz_session'), 0);
      expect(await _count(database, 'quiz_answer'), 0);
    });
    test('refuses two answers at the same position', () async {
      // Arrange
      await database.insert('quiz_session', _sessionRow);
      await database.insert('quiz_answer', _answerRow(1));
      // Act
      Future<int> actualInsert() =>
          database.insert('quiz_answer', _answerRow(1));
      // Assert
      await expectLater(actualInsert, throwsA(isA<DatabaseException>()));
    });
    test('upgrades a version 1 database and keeps its profiles', () async {
      // Arrange
      final String inputPath =
          '${await databaseFactoryFfi.getDatabasesPath()}'
          '/migration_002_upgrade_test.db';
      await databaseFactoryFfi.deleteDatabase(inputPath);
      final AppDatabase versionOne = _openDatabase(
        const <DatabaseMigration>[Migration001CreateProfileTables()],
        inputPath,
      );
      await (await versionOne.database).insert('profile', _profileRow);
      await versionOne.close();
      // Act
      final AppDatabase versionTwo = _openDatabase(
        const <DatabaseMigration>[
          Migration001CreateProfileTables(),
          Migration002CreateQuizSessionTables(),
        ],
        inputPath,
      );
      final Database upgraded = await versionTwo.database;
      // Assert
      expect(await _count(upgraded, 'profile'), 1);
      expect(await _count(upgraded, 'quiz_session'), 0);
      await versionTwo.close();
      await databaseFactoryFfi.deleteDatabase(inputPath);
    });
  });
}
