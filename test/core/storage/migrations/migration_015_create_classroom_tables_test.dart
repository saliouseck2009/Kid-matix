import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Map<String, Object?> _profileRow(
  String id,
  String nickname, {
  String? classroomId,
}) {
  return <String, Object?>{
    'id': id,
    'nickname': nickname,
    'normalized_nickname': nickname.toLowerCase(),
    'avatar': 'avatar1',
    'color': 'violet',
    'created_at': 0,
    'updated_at': 0,
    'classroom_id': ?classroomId,
  };
}

Map<String, Object?> _classroomRow(String id) {
  return <String, Object?>{
    'id': id,
    'name': 'CE1 $id',
    'weekly_goal': 1000,
    'created_at': 0,
    'updated_at': 0,
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

  group('Migration 15', () {
    late AppDatabase appDatabase;
    late Database database;

    setUp(() async {
      appDatabase = _openDatabase(appMigrations, inMemoryDatabasePath);
      database = await appDatabase.database;
      await database.insert('classroom', _classroomRow('c1'));
      await database.insert('classroom', _classroomRow('c2'));
    });

    tearDown(() => appDatabase.close());

    test('is the last migration of the app', () {
      // Assert
      expect(appMigrations.last.version, 15);
    });

    test('upgrades a version 13 database: players stay free', () async {
      // Arrange
      final String inputPath =
          '${await databaseFactoryFfi.getDatabasesPath()}'
          '/migration_015_upgrade_test.db';
      await databaseFactoryFfi.deleteDatabase(inputPath);
      final AppDatabase versionThirteen = _openDatabase(
        appMigrations.take(13).toList(),
        inputPath,
      );
      await (await versionThirteen.database).insert(
        'profile',
        _profileRow('p1', 'Awa'),
      );
      await versionThirteen.close();
      // Act
      final AppDatabase upgraded = _openDatabase(appMigrations, inputPath);
      final Database upgradedDatabase = await upgraded.database;
      // Assert
      final List<Map<String, Object?>> actualRows = await upgradedDatabase
          .query('profile');
      expect(await upgradedDatabase.getVersion(), 15);
      expect(actualRows.single['nickname'], 'Awa');
      expect(actualRows.single['classroom_id'], isNull);
      await upgraded.close();
      await databaseFactoryFfi.deleteDatabase(inputPath);
    });

    test('upgraded from 13, lets a free and a pupil « Awa » coexist', () async {
      // Arrange
      final String inputPath =
          '${await databaseFactoryFfi.getDatabasesPath()}'
          '/migration_015_nickname_test.db';
      await databaseFactoryFfi.deleteDatabase(inputPath);
      final AppDatabase versionThirteen = _openDatabase(
        appMigrations.take(13).toList(),
        inputPath,
      );
      await (await versionThirteen.database).insert(
        'profile',
        _profileRow('p1', 'Awa'),
      );
      await versionThirteen.close();
      final AppDatabase upgraded = _openDatabase(appMigrations, inputPath);
      final Database upgradedDatabase = await upgraded.database;
      await upgradedDatabase.insert('classroom', _classroomRow('c1'));
      // Act
      await upgradedDatabase.insert(
        'profile',
        _profileRow('p2', 'Awa', classroomId: 'c1'),
      );
      // Assert
      final List<Map<String, Object?>> actualIndexes = await upgradedDatabase
          .rawQuery(
            "SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND name = 'profile_normalized_nickname_unique'",
          );
      expect(actualIndexes, isEmpty);
      expect(await upgradedDatabase.query('profile'), hasLength(2));
      await upgraded.close();
      await databaseFactoryFfi.deleteDatabase(inputPath);
    });

    test('keeps a nickname unique among the free players', () async {
      // Arrange
      await database.insert('profile', _profileRow('p1', 'Awa'));
      // Act
      Future<int> actualInsert() {
        return database.insert('profile', _profileRow('p2', 'Awa'));
      }

      // Assert
      await expectLater(actualInsert(), throwsA(isA<DatabaseException>()));
    });

    test('lets two classes and a free player share a nickname', () async {
      // Arrange
      await database.insert('profile', _profileRow('p1', 'Awa'));
      // Act
      await database.insert(
        'profile',
        _profileRow('p2', 'Awa', classroomId: 'c1'),
      );
      await database.insert(
        'profile',
        _profileRow('p3', 'Awa', classroomId: 'c2'),
      );
      // Assert
      expect(await database.query('profile'), hasLength(3));
    });

    test('keeps a nickname unique inside a class', () async {
      // Arrange
      await database.insert(
        'profile',
        _profileRow('p1', '01', classroomId: 'c1'),
      );
      // Act
      Future<int> actualInsert() {
        return database.insert(
          'profile',
          _profileRow('p2', '01', classroomId: 'c1'),
        );
      }

      // Assert
      await expectLater(actualInsert(), throwsA(isA<DatabaseException>()));
    });

    test('deletes the results of a pupil with the pupil', () async {
      // Arrange
      await database.insert(
        'profile',
        _profileRow('p1', '01', classroomId: 'c1'),
      );
      await database.insert('class_session', <String, Object?>{
        'id': 's1',
        'profile_id': 'p1',
        'classroom_id': 'c1',
        'domain_id': 'addition',
        'started_at': 0,
        'duration_ms': 60000,
        'question_count': 10,
        'correct_count': 8,
        'updated_at': 0,
      });
      await database.insert('class_answer', <String, Object?>{
        'session_id': 's1',
        'position': 0,
        'item_key': 'add:7+8',
        'is_correct': 0,
        'is_retry': 0,
        'updated_at': 0,
      });
      // Act
      await database.delete('profile', where: "id = 'p1'");
      // Assert
      expect(await database.query('class_session'), isEmpty);
      expect(await database.query('class_answer'), isEmpty);
    });

    test('refuses an assignment of an unknown class', () async {
      // Act
      Future<int> actualInsert() {
        return database.insert('assignment', <String, Object?>{
          'id': 'a1',
          'classroom_id': 'nowhere',
          'domain_id': 'addition',
          'unit_key': 'addsub:sums-20',
          'created_at': 0,
          'updated_at': 0,
        });
      }

      // Assert
      await expectLater(actualInsert(), throwsA(isA<DatabaseException>()));
    });
  });
}
