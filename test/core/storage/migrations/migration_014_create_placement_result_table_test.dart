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

Map<String, Object?> _resultRow({
  int takenAt = 1000,
  String domainId = 'numbers',
  int? level = 1,
  String? startUnitKey,
}) {
  return <String, Object?>{
    'profile_id': 'p1',
    'taken_at': takenAt,
    'domain_id': domainId,
    'level': level,
    'skill_count': 1,
    'unit_count': 3,
    'start_unit_key': startUnitKey,
    'updated_at': takenAt,
  };
}

AppDatabase _openDatabase(List<DatabaseMigration> migrations, String path) {
  return AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => path,
    migrationRunner: MigrationRunner(migrations: migrations),
  );
}

void main() {
  setUpAll(sqfliteFfiInit);

  group('Migration 14', () {
    test('is the fourteenth migration of the app', () {
      // Assert
      expect(appMigrations[13].version, 14);
    });

    test('upgrades a version 13 database: the table is added', () async {
      // Arrange
      final String inputPath =
          '${await databaseFactoryFfi.getDatabasesPath()}'
          '/migration_014_upgrade_test.db';
      await databaseFactoryFfi.deleteDatabase(inputPath);
      final AppDatabase versionThirteen = _openDatabase(
        appMigrations.take(13).toList(),
        inputPath,
      );
      final Database oldDatabase = await versionThirteen.database;
      await oldDatabase.insert('profile', _profileRow);
      await versionThirteen.close();
      // Act
      final AppDatabase versionFourteen = _openDatabase(
        appMigrations.take(14).toList(),
        inputPath,
      );
      final Database upgraded = await versionFourteen.database;
      // Assert
      expect(await upgraded.getVersion(), 14);
      expect(await upgraded.query('placement_result'), isEmpty);
      expect(await upgraded.query('profile'), hasLength(1));
      await versionFourteen.close();
      await databaseFactoryFfi.deleteDatabase(inputPath);
    });

    test('keeps every test of a player, one row per test and domain', () async {
      // Arrange
      final AppDatabase appDatabase = _openDatabase(
        appMigrations.take(14).toList(),
        inMemoryDatabasePath,
      );
      final Database database = await appDatabase.database;
      await database.insert('profile', _profileRow);
      // Act
      await database.insert('placement_result', _resultRow());
      await database.insert(
        'placement_result',
        _resultRow(domainId: 'addition', startUnitKey: 'addsub:add5'),
      );
      await database.insert('placement_result', _resultRow(takenAt: 2000));
      // Assert
      expect(await database.query('placement_result'), hasLength(3));
      await expectLater(
        database.insert('placement_result', _resultRow()),
        throwsA(isA<DatabaseException>()),
      );
      await appDatabase.close();
    });

    test('stores a domain the test did not reach apart from level 0', () async {
      // Arrange
      final AppDatabase appDatabase = _openDatabase(
        appMigrations.take(14).toList(),
        inMemoryDatabasePath,
      );
      final Database database = await appDatabase.database;
      await database.insert('profile', _profileRow);
      // Act
      await database.insert(
        'placement_result',
        _resultRow(domainId: 'division', level: null),
      );
      await database.insert(
        'placement_result',
        _resultRow(domainId: 'addition', level: 0),
      );
      // Assert
      final List<Map<String, Object?>> actualRows = await database.query(
        'placement_result',
        orderBy: 'domain_id',
      );
      expect(actualRows.map((Map<String, Object?> r) => r['level']), <int?>[
        0,
        null,
      ]);
      await appDatabase.close();
    });

    test('deletes the results of a deleted profile', () async {
      // Arrange
      final AppDatabase appDatabase = _openDatabase(
        appMigrations.take(14).toList(),
        inMemoryDatabasePath,
      );
      final Database database = await appDatabase.database;
      await database.insert('profile', _profileRow);
      await database.insert('placement_result', _resultRow());
      // Act
      await database.delete('profile', where: 'id = ?', whereArgs: ['p1']);
      // Assert
      expect(await database.query('placement_result'), isEmpty);
      await appDatabase.close();
    });
  });
}
