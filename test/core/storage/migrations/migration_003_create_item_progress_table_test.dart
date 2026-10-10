import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/migrations/migration_001_create_profile_tables.dart';
import 'package:kid_matix/core/storage/migrations/migration_002_create_quiz_session_tables.dart';
import 'package:kid_matix/core/storage/migrations/migration_003_create_item_progress_table.dart';
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

Map<String, Object?> _progressRow(String itemKey) => <String, Object?>{
  'profile_id': 'p1',
  'domain_id': 'multiplication',
  'item_key': itemKey,
  'presentation_count': 1,
  'correct_count': 1,
  'last_answer_times_ms': '2400',
  'box': 1,
  'next_review_at': 0,
  'updated_at': 0,
};

const List<DatabaseMigration> _versionTwo = <DatabaseMigration>[
  Migration001CreateProfileTables(),
  Migration002CreateQuizSessionTables(),
];

const List<DatabaseMigration> _versionThree = <DatabaseMigration>[
  ..._versionTwo,
  Migration003CreateItemProgressTable(),
];

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
    appDatabase = _openDatabase(_versionThree, inMemoryDatabasePath);
    database = await appDatabase.database;
    await database.insert('profile', _profileRow);
  });

  tearDown(() => appDatabase.close());

  group('Migration 3', () {
    test('stores one row per item of a player', () async {
      // Act
      await database.insert('item_progress', _progressRow('mul:7x8'));
      await database.insert('item_progress', _progressRow('mul:8x7'));
      // Assert
      expect(await _count(database, 'item_progress'), 2);
    });
    test('refuses a second row for the same item', () async {
      // Arrange
      await database.insert('item_progress', _progressRow('mul:7x8'));
      // Act
      Future<int> actualInsert() =>
          database.insert('item_progress', _progressRow('mul:7x8'));
      // Assert
      await expectLater(actualInsert, throwsA(isA<DatabaseException>()));
    });
    test('deletes the progress of a deleted profile', () async {
      // Arrange
      await database.insert('item_progress', _progressRow('mul:7x8'));
      // Act
      await database.delete('profile');
      // Assert
      expect(await _count(database, 'item_progress'), 0);
    });
    test('upgrades a version 2 database and keeps its data', () async {
      // Arrange
      final String inputPath =
          '${await databaseFactoryFfi.getDatabasesPath()}'
          '/migration_003_upgrade_test.db';
      await databaseFactoryFfi.deleteDatabase(inputPath);
      final AppDatabase versionTwo = _openDatabase(_versionTwo, inputPath);
      await (await versionTwo.database).insert('profile', _profileRow);
      await versionTwo.close();
      // Act
      final AppDatabase versionThree = _openDatabase(_versionThree, inputPath);
      final Database upgraded = await versionThree.database;
      // Assert
      expect(await upgraded.getVersion(), 3);
      expect(await _count(upgraded, 'profile'), 1);
      expect(await _count(upgraded, 'item_progress'), 0);
      await versionThree.close();
      await databaseFactoryFfi.deleteDatabase(inputPath);
    });
  });
}
