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

const Map<String, Object?> _settingsRow = <String, Object?>{
  'profile_id': 'p1',
  'timer_mode': 'normal',
  'daily_goal_xp': 20,
  'is_sound_enabled': 1,
  'is_vibration_enabled': 1,
  'is_reduced_motion_enabled': 0,
  'is_everything_unlocked': 0,
  'updated_at': 0,
};

AppDatabase _openDatabase(List<DatabaseMigration> migrations, String path) {
  return AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => path,
    migrationRunner: MigrationRunner(migrations: migrations),
  );
}

void main() {
  setUpAll(sqfliteFfiInit);

  group('Migration 12', () {
    test(
      'upgrades a version 11 database: settings kept, reading off',
      () async {
        // Arrange
        final String inputPath =
            '${await databaseFactoryFfi.getDatabasesPath()}'
            '/migration_012_upgrade_test.db';
        await databaseFactoryFfi.deleteDatabase(inputPath);
        final AppDatabase versionEleven = _openDatabase(
          appMigrations.take(11).toList(),
          inputPath,
        );
        final Database oldDatabase = await versionEleven.database;
        await oldDatabase.insert('profile', _profileRow);
        await oldDatabase.insert('profile_settings', _settingsRow);
        await versionEleven.close();
        // Act
        final AppDatabase versionTwelve = _openDatabase(
          appMigrations.take(12).toList(),
          inputPath,
        );
        final Database upgraded = await versionTwelve.database;
        // Assert
        final List<Map<String, Object?>> actualRows = await upgraded.query(
          'profile_settings',
        );
        expect(await upgraded.getVersion(), 12);
        expect(actualRows.single['is_read_aloud_enabled'], 0);
        expect(actualRows.single['daily_goal_xp'], 20);
        await versionTwelve.close();
        await databaseFactoryFfi.deleteDatabase(inputPath);
      },
    );

    test('stores the setting of a new player', () async {
      // Arrange
      final AppDatabase appDatabase = _openDatabase(
        appMigrations.take(12).toList(),
        inMemoryDatabasePath,
      );
      final Database database = await appDatabase.database;
      await database.insert('profile', _profileRow);
      // Act
      await database.insert('profile_settings', <String, Object?>{
        ..._settingsRow,
        'is_read_aloud_enabled': 1,
      });
      // Assert
      final List<Map<String, Object?>> actualRows = await database.query(
        'profile_settings',
      );
      expect(actualRows.single['is_read_aloud_enabled'], 1);
      await appDatabase.close();
    });
  });
}
