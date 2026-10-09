import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String _listTablesQuery =
    "SELECT name FROM sqlite_master WHERE type = 'table'";

/// Test migration that creates one empty table.
final class _CreateTableMigration implements DatabaseMigration {
  const _CreateTableMigration({required this.version, required this.table});

  @override
  final int version;

  final String table;

  @override
  Future<void> migrate(Database database) {
    return database.execute('CREATE TABLE $table (id INTEGER PRIMARY KEY)');
  }
}

AppDatabase _createDatabase({
  required String path,
  required List<DatabaseMigration> migrations,
}) {
  return AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => path,
    migrationRunner: MigrationRunner(migrations: migrations),
  );
}

Future<List<String>> _readTableNames(AppDatabase appDatabase) async {
  final Database database = await appDatabase.database;
  final List<Map<String, Object?>> rows = await database.rawQuery(
    _listTablesQuery,
  );
  return rows
      .map((Map<String, Object?> row) => row['name']! as String)
      .toList();
}

void main() {
  const DatabaseMigration inputFirstMigration = _CreateTableMigration(
    version: 1,
    table: 'first_table',
  );
  const DatabaseMigration inputSecondMigration = _CreateTableMigration(
    version: 2,
    table: 'second_table',
  );
  const List<String> expectedTables = <String>[
    'first_table',
    'second_table',
  ];
  late Directory temporaryDirectory;
  setUpAll(sqfliteFfiInit);
  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('kid_matix_');
  });
  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });
  group('MigrationRunner', () {
    test('latestVersion is the highest migration version', () {
      // Arrange
      final MigrationRunner inputRunner = MigrationRunner(
        migrations: <DatabaseMigration>[
          inputSecondMigration,
          inputFirstMigration,
        ],
      );
      const int expectedVersion = 2;
      // Act
      final int actualVersion = inputRunner.latestVersion;
      // Assert
      expect(actualVersion, expectedVersion);
    });
    test('latestVersion is 0 when there is no migration', () {
      // Arrange
      final MigrationRunner inputRunner = MigrationRunner(
        migrations: <DatabaseMigration>[],
      );
      // Act
      final int actualVersion = inputRunner.latestVersion;
      // Assert
      expect(actualVersion, 0);
    });
  });
  group('AppDatabase', () {
    test('a new database runs every migration', () async {
      // Arrange
      final AppDatabase inputDatabase = _createDatabase(
        path: inMemoryDatabasePath,
        migrations: <DatabaseMigration>[
          inputFirstMigration,
          inputSecondMigration,
        ],
      );
      // Act
      final List<String> actualTables = await _readTableNames(inputDatabase);
      await inputDatabase.close();
      // Assert
      expect(actualTables, containsAll(expectedTables));
    });
    test('an existing database runs only the pending migrations', () async {
      // Arrange
      final String inputPath = join(temporaryDirectory.path, 'upgrade.db');
      final AppDatabase inputOldDatabase = _createDatabase(
        path: inputPath,
        migrations: <DatabaseMigration>[inputFirstMigration],
      );
      await inputOldDatabase.database;
      await inputOldDatabase.close();
      final AppDatabase inputNewDatabase = _createDatabase(
        path: inputPath,
        migrations: <DatabaseMigration>[
          inputFirstMigration,
          inputSecondMigration,
        ],
      );
      // Act
      final List<String> actualTables = await _readTableNames(
        inputNewDatabase,
      );
      await inputNewDatabase.close();
      // Assert
      expect(actualTables, containsAll(expectedTables));
    });
    test('foreign keys are enforced', () async {
      // Arrange
      final AppDatabase inputDatabase = _createDatabase(
        path: inMemoryDatabasePath,
        migrations: <DatabaseMigration>[inputFirstMigration],
      );
      final Database database = await inputDatabase.database;
      // Act
      final List<Map<String, Object?>> actualRows = await database.rawQuery(
        'PRAGMA foreign_keys',
      );
      await inputDatabase.close();
      // Assert
      expect(actualRows.single['foreign_keys'], 1);
    });
  });
}
