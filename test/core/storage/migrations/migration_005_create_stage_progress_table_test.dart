import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
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

Map<String, Object?> _stageRow(String stage) => <String, Object?>{
  'profile_id': 'p1',
  'domain_id': 'multiplication',
  'unit_key': 'mul:5',
  'stage': stage,
  'best_stars': 2,
  'best_score': 8,
  'completed_at': 0,
  'updated_at': 0,
};

AppDatabase _openDatabase(List<DatabaseMigration> migrations, String path) {
  return AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => path,
    migrationRunner: MigrationRunner(migrations: migrations),
  );
}

Future<int> _count(Database database) async {
  final List<Map<String, Object?>> rows = await database.rawQuery(
    'SELECT COUNT(*) AS n FROM stage_progress',
  );
  return rows.single['n']! as int;
}

void main() {
  late AppDatabase appDatabase;
  late Database database;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = _openDatabase(appMigrations, inMemoryDatabasePath);
    database = await appDatabase.database;
    await database.insert('profile', _profileRow);
  });

  tearDown(() => appDatabase.close());

  group('Migration 5', () {
    test('stores one row per stage of a table', () async {
      // Act
      await database.insert('stage_progress', _stageRow('discovery'));
      await database.insert('stage_progress', _stageRow('training'));
      // Assert
      expect(await _count(database), 2);
    });
    test('refuses a second row for the same stage', () async {
      // Arrange
      await database.insert('stage_progress', _stageRow('discovery'));
      // Act
      Future<int> actualInsert() =>
          database.insert('stage_progress', _stageRow('discovery'));
      // Assert
      await expectLater(actualInsert, throwsA(isA<DatabaseException>()));
    });
    test('deletes the stages of a deleted profile', () async {
      // Arrange
      await database.insert('stage_progress', _stageRow('discovery'));
      // Act
      await database.delete('profile');
      // Assert
      expect(await _count(database), 0);
    });
    test('upgrades a version 4 database and keeps its data', () async {
      // Arrange
      final String inputPath =
          '${await databaseFactoryFfi.getDatabasesPath()}'
          '/migration_005_upgrade_test.db';
      await databaseFactoryFfi.deleteDatabase(inputPath);
      final AppDatabase versionFour = _openDatabase(
        appMigrations.take(4).toList(),
        inputPath,
      );
      await (await versionFour.database).insert('profile', _profileRow);
      await versionFour.close();
      // Act
      final AppDatabase versionFive = _openDatabase(appMigrations, inputPath);
      final Database upgraded = await versionFive.database;
      // Assert
      expect(await upgraded.getVersion(), 5);
      expect(await upgraded.query('profile'), hasLength(1));
      expect(await _count(upgraded), 0);
      await versionFive.close();
      await databaseFactoryFfi.deleteDatabase(inputPath);
    });
  });
}
