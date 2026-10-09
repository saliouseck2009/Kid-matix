import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Map<String, Object?> _profileRow({
  required String id,
  required String normalizedNickname,
}) {
  return <String, Object?>{
    'id': id,
    'nickname': normalizedNickname,
    'normalized_nickname': normalizedNickname,
    'avatar': 'avatar1',
    'color': 'violet',
    'created_at': 0,
    'updated_at': 0,
  };
}

Map<String, Object?> _settingsRow({required String profileId}) {
  return <String, Object?>{
    'profile_id': profileId,
    'timer_mode': 'normal',
    'daily_goal_xp': 20,
    'is_sound_enabled': 1,
    'is_vibration_enabled': 1,
    'is_reduced_motion_enabled': 0,
    'is_everything_unlocked': 0,
    'updated_at': 0,
  };
}

Future<List<String>> _readColumns(Database database, String table) async {
  final List<Map<String, Object?>> rows = await database.rawQuery(
    'PRAGMA table_info($table)',
  );
  return rows
      .map((Map<String, Object?> row) => row['name']! as String)
      .toList();
}

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
  });

  tearDown(() => appDatabase.close());

  group('Migration 1', () {
    test('creates the profile table with the common columns', () async {
      // Arrange
      const List<String> expectedColumns = <String>[
        'id',
        'remote_account_id',
        'nickname',
        'normalized_nickname',
        'avatar',
        'color',
        'total_xp',
        'level',
        'created_at',
        'last_played_at',
        'updated_at',
        'deleted_at',
      ];
      // Act
      final List<String> actualColumns = await _readColumns(
        database,
        'profile',
      );
      // Assert
      expect(actualColumns, expectedColumns);
    });
    test('creates the profile_settings table', () async {
      // Arrange
      const List<String> expectedColumns = <String>[
        'profile_id',
        'timer_mode',
        'daily_goal_xp',
        'is_sound_enabled',
        'is_vibration_enabled',
        'is_reduced_motion_enabled',
        'is_everything_unlocked',
        'updated_at',
        'deleted_at',
      ];
      // Act
      final List<String> actualColumns = await _readColumns(
        database,
        'profile_settings',
      );
      // Assert
      expect(actualColumns, expectedColumns);
    });
    test('gives a new profile no XP, level 1 and no remote account', () async {
      // Arrange
      await database.insert(
        'profile',
        _profileRow(id: 'p1', normalizedNickname: 'awa'),
      );
      // Act
      final List<Map<String, Object?>> actualRows = await database.query(
        'profile',
      );
      // Assert
      expect(actualRows.single['total_xp'], 0);
      expect(actualRows.single['level'], 1);
      expect(actualRows.single['remote_account_id'], isNull);
    });
    test(
      'refuses two live profiles with the same normalized nickname',
      () async {
        // Arrange
        await database.insert(
          'profile',
          _profileRow(id: 'p1', normalizedNickname: 'awa'),
        );
        // Act
        Future<int> actualInsert() => database.insert(
          'profile',
          _profileRow(id: 'p2', normalizedNickname: 'awa'),
        );
        // Assert
        await expectLater(actualInsert, throwsA(isA<DatabaseException>()));
      },
    );
    test('deletes the settings of a deleted profile', () async {
      // Arrange
      await database.insert(
        'profile',
        _profileRow(id: 'p1', normalizedNickname: 'awa'),
      );
      await database.insert('profile_settings', _settingsRow(profileId: 'p1'));
      // Act
      await database.delete(
        'profile',
        where: 'id = ?',
        whereArgs: <Object>['p1'],
      );
      // Assert
      final List<Map<String, Object?>> actualRows = await database.query(
        'profile_settings',
      );
      expect(actualRows, isEmpty);
    });
    test('refuses settings for a profile that does not exist', () async {
      // Act
      Future<int> actualInsert() => database.insert(
        'profile_settings',
        _settingsRow(profileId: 'missing'),
      );
      // Assert
      await expectLater(actualInsert, throwsA(isA<DatabaseException>()));
    });
  });
}
