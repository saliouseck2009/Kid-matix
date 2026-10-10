import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/migrations/migration_001_create_profile_tables.dart';
import 'package:kid_matix/core/storage/migrations/migration_002_create_quiz_session_tables.dart';
import 'package:kid_matix/core/storage/migrations/migration_003_create_item_progress_table.dart';
import 'package:kid_matix/core/storage/migrations/migration_004_add_quiz_session_source.dart';
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

const List<DatabaseMigration> _versionThree = <DatabaseMigration>[
  Migration001CreateProfileTables(),
  Migration002CreateQuizSessionTables(),
  Migration003CreateItemProgressTable(),
];

AppDatabase _openDatabase(List<DatabaseMigration> migrations, String path) {
  return AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => path,
    migrationRunner: MigrationRunner(migrations: migrations),
  );
}

void main() {
  setUpAll(sqfliteFfiInit);

  group('Migration 4', () {
    test(
      'keeps the old sessions without a source and stores new ones',
      () async {
        // Arrange
        final String inputPath =
            '${await databaseFactoryFfi.getDatabasesPath()}'
            '/migration_004_upgrade_test.db';
        await databaseFactoryFfi.deleteDatabase(inputPath);
        final AppDatabase versionThree = _openDatabase(
          _versionThree,
          inputPath,
        );
        final Database oldDatabase = await versionThree.database;
        await oldDatabase.insert('profile', _profileRow);
        await oldDatabase.insert('quiz_session', _sessionRow('old'));
        await versionThree.close();
        // Act
        final AppDatabase versionFour = _openDatabase(<DatabaseMigration>[
          ..._versionThree,
          const Migration004AddQuizSessionSource(),
        ], inputPath);
        final Database upgraded = await versionFour.database;
        await upgraded.insert('quiz_session', <String, Object?>{
          ..._sessionRow('new'),
          'source_key': 'path:mul:5:training',
        });
        // Assert
        final List<Map<String, Object?>> actualRows = await upgraded.query(
          'quiz_session',
          orderBy: 'id DESC',
        );
        expect(await upgraded.getVersion(), 4);
        expect(actualRows.first['source_key'], isNull);
        expect(actualRows.last['source_key'], 'path:mul:5:training');
        await versionFour.close();
        await databaseFactoryFfi.deleteDatabase(inputPath);
      },
    );
  });
}
