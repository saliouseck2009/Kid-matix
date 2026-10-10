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

  group('Migration 7', () {
    test('stores the rewards and deletes them with the profile', () async {
      // Arrange
      final AppDatabase appDatabase = _openDatabase(
        appMigrations.take(7).toList(),
        inMemoryDatabasePath,
      );
      final Database database = await appDatabase.database;
      await database.insert('profile', _profileRow);
      await database.insert('quiz_session', <String, Object?>{
        'id': 's1',
        'profile_id': 'p1',
        'domain_id': 'multiplication',
        'mode': 'path',
        'status': 'completed',
        'started_at': 0,
        'duration_ms': 1,
        'question_count': 10,
        'correct_count': 10,
        'updated_at': 0,
      });
      // Act
      await database.insert('session_reward', <String, Object?>{
        'session_id': 's1',
        'profile_id': 'p1',
        'xp_earned': 170,
        'xp_version': 1,
        'earned_at': 0,
        'updated_at': 0,
      });
      await database.insert('streak', <String, Object?>{
        'profile_id': 'p1',
        'current_streak': 1,
        'best_streak': 1,
        'updated_at': 0,
      });
      await database.insert('badge_unlock', <String, Object?>{
        'profile_id': 'p1',
        'badge_key': 'firstStep',
        'unlocked_at': 0,
        'session_id': 's1',
        'updated_at': 0,
      });
      await database.insert('reward_stats', <String, Object?>{
        'profile_id': 'p1',
        'lightning_answers': 3,
        'updated_at': 0,
      });
      await database.delete('profile');
      // Assert
      for (final String table in <String>[
        'session_reward',
        'streak',
        'badge_unlock',
        'reward_stats',
      ]) {
        expect(await _count(database, table), 0, reason: table);
      }
      await appDatabase.close();
    });
    test('upgrades a version 6 database and keeps its data', () async {
      // Arrange
      final String inputPath =
          '${await databaseFactoryFfi.getDatabasesPath()}'
          '/migration_007_upgrade_test.db';
      await databaseFactoryFfi.deleteDatabase(inputPath);
      final AppDatabase versionSix = _openDatabase(
        appMigrations.take(6).toList(),
        inputPath,
      );
      await (await versionSix.database).insert('profile', _profileRow);
      await versionSix.close();
      // Act
      final AppDatabase versionSeven = _openDatabase(
        appMigrations.take(7).toList(),
        inputPath,
      );
      final Database upgraded = await versionSeven.database;
      // Assert
      expect(await upgraded.getVersion(), 7);
      expect(await _count(upgraded, 'profile'), 1);
      expect(await _count(upgraded, 'streak'), 0);
      await versionSeven.close();
      await databaseFactoryFfi.deleteDatabase(inputPath);
    });
  });
}
