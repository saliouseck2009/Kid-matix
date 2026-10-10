import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/migrations/migration_006_add_quiz_session_boss_outcome.dart';
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

Map<String, Object?> _sessionRow(String id) => <String, Object?>{
  'id': id,
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

final List<DatabaseMigration> _versionFive = appMigrations.take(5).toList();

AppDatabase _openDatabase(List<DatabaseMigration> migrations, String path) {
  return AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => path,
    migrationRunner: MigrationRunner(migrations: migrations),
  );
}

void main() {
  setUpAll(sqfliteFfiInit);

  group('Migration 6', () {
    test(
      'keeps the old sessions without an outcome and stores new ones',
      () async {
        // Arrange
        final String inputPath =
            '${await databaseFactoryFfi.getDatabasesPath()}'
            '/migration_006_upgrade_test.db';
        await databaseFactoryFfi.deleteDatabase(inputPath);
        final AppDatabase versionFive = _openDatabase(
          _versionFive,
          inputPath,
        );
        final Database oldDatabase = await versionFive.database;
        await oldDatabase.insert('profile', _profileRow);
        await oldDatabase.insert('quiz_session', _sessionRow('old'));
        await versionFive.close();
        // Act
        final AppDatabase versionSix = _openDatabase(<DatabaseMigration>[
          ..._versionFive,
          const Migration006AddQuizSessionBossOutcome(),
        ], inputPath);
        final Database upgraded = await versionSix.database;
        await upgraded.insert('quiz_session', <String, Object?>{
          ..._sessionRow('new'),
          'boss_outcome': 'defeated',
        });
        // Assert
        final List<Map<String, Object?>> actualRows = await upgraded.query(
          'quiz_session',
          orderBy: 'id DESC',
        );
        expect(await upgraded.getVersion(), 6);
        expect(actualRows.first['boss_outcome'], isNull);
        expect(actualRows.last['boss_outcome'], 'defeated');
        await versionSix.close();
        await databaseFactoryFfi.deleteDatabase(inputPath);
      },
    );
  });
}
