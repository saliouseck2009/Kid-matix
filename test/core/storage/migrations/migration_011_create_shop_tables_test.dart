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

const Map<String, Object?> _purchaseRow = <String, Object?>{
  'id': 'b1',
  'profile_id': 'p1',
  'item_id': 'avatar:fox',
  'price': 80,
  'purchased_at': 0,
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

  group('Migration 11', () {
    test('stores purchases once per item and deletes them with the '
        'profile', () async {
      // Arrange
      final AppDatabase appDatabase = _openDatabase(
        appMigrations.take(11).toList(),
        inMemoryDatabasePath,
      );
      final Database database = await appDatabase.database;
      await database.insert('profile', _profileRow);
      await database.insert('shop_purchase', _purchaseRow);
      await database.insert('shop_choice', <String, Object?>{
        'profile_id': 'p1',
        'theme_id': 'ocean',
        'updated_at': 0,
      });
      // Act
      final Future<int> actualDuplicate = database.insert(
        'shop_purchase',
        <String, Object?>{..._purchaseRow, 'id': 'b2'},
      );
      // Assert
      await expectLater(actualDuplicate, throwsA(isA<DatabaseException>()));
      await database.delete('profile');
      expect(await _count(database, 'shop_purchase'), 0);
      expect(await _count(database, 'shop_choice'), 0);
      await appDatabase.close();
    });

    test('upgrades a version 10 database and keeps its data', () async {
      // Arrange
      final String inputPath =
          '${await databaseFactoryFfi.getDatabasesPath()}'
          '/migration_011_upgrade_test.db';
      await databaseFactoryFfi.deleteDatabase(inputPath);
      final AppDatabase versionTen = _openDatabase(
        appMigrations.take(10).toList(),
        inputPath,
      );
      await (await versionTen.database).insert('profile', _profileRow);
      await versionTen.close();
      // Act
      final AppDatabase versionEleven = _openDatabase(
        appMigrations.take(11).toList(),
        inputPath,
      );
      final Database upgraded = await versionEleven.database;
      // Assert
      expect(await upgraded.getVersion(), 11);
      expect(await _count(upgraded, 'profile'), 1);
      expect(await _count(upgraded, 'shop_purchase'), 0);
      expect(await _count(upgraded, 'shop_choice'), 0);
      await versionEleven.close();
      await databaseFactoryFfi.deleteDatabase(inputPath);
    });
  });
}
