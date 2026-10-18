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
  setUpAll(sqfliteFfiInit);

  group('Migration 10', () {
    test('stores the XP awards and deletes them with the profile', () async {
      // Arrange
      final AppDatabase appDatabase = _openDatabase(
        appMigrations.take(10).toList(),
        inMemoryDatabasePath,
      );
      final Database database = await appDatabase.database;
      await database.insert('profile', _profileRow);
      await database.insert('xp_award', <String, Object?>{
        'id': 'a1',
        'profile_id': 'p1',
        'source_key': 'duel',
        'xp_earned': 120,
        'earned_at': 0,
        'updated_at': 0,
      });
      // Act
      await database.delete('profile');
      // Assert
      expect(await _count(database, 'xp_award'), 0);
      await appDatabase.close();
    });
    test('upgrades a version 9 database and keeps its data', () async {
      // Arrange
      final String inputPath =
          '${await databaseFactoryFfi.getDatabasesPath()}'
          '/migration_010_upgrade_test.db';
      await databaseFactoryFfi.deleteDatabase(inputPath);
      final AppDatabase versionNine = _openDatabase(
        appMigrations.take(9).toList(),
        inputPath,
      );
      await (await versionNine.database).insert('profile', _profileRow);
      await versionNine.close();
      // Act
      final AppDatabase versionTen = _openDatabase(
        appMigrations.take(10).toList(),
        inputPath,
      );
      final Database upgraded = await versionTen.database;
      // Assert
      expect(await upgraded.getVersion(), 10);
      expect(await _count(upgraded, 'profile'), 1);
      expect(await _count(upgraded, 'xp_award'), 0);
      await versionTen.close();
      await databaseFactoryFfi.deleteDatabase(inputPath);
    });
  });
}
