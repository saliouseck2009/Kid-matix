import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Map<String, Object?> _profileRow(String id) {
  return <String, Object?>{
    'id': id,
    'nickname': 'Awa $id',
    'normalized_nickname': 'awa $id',
    'avatar': 'avatar1',
    'color': 'violet',
    'created_at': 0,
    'updated_at': 0,
    'classroom_id': 'c1',
  };
}

const Map<String, Object?> _classroomRow = <String, Object?>{
  'id': 'c1',
  'name': 'CE1',
  'weekly_goal': 1000,
  'created_at': 0,
  'updated_at': 0,
};

const Map<String, Object?> _assessmentRow = <String, Object?>{
  'id': 'a1',
  'classroom_id': 'c1',
  'period_label': "Début d'année",
  'opened_at': 1000,
  'updated_at': 1000,
};

Map<String, Object?> _resultRow(String profileId) {
  return <String, Object?>{
    'assessment_id': 'a1',
    'profile_id': profileId,
    'taken_at': 2000,
    'word_count': 12,
    'understood_word_count': 7,
    'updated_at': 2000,
  };
}

AppDatabase _openDatabase(List<DatabaseMigration> migrations, String path) {
  return AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => path,
    migrationRunner: MigrationRunner(migrations: migrations),
  );
}

Future<Database> _seed(AppDatabase appDatabase) async {
  final Database database = await appDatabase.database;
  await database.insert('classroom', _classroomRow);
  await database.insert('profile', _profileRow('p1'));
  await database.insert('class_assessment', _assessmentRow);
  await database.insert('assessment_result', _resultRow('p1'));
  await database.insert('assessment_level', <String, Object?>{
    'assessment_id': 'a1',
    'profile_id': 'p1',
    'domain_id': 'division',
    'level': null,
    'skill_count': 1,
    'updated_at': 2000,
  });
  await database.insert('assessment_word', <String, Object?>{
    'assessment_id': 'a1',
    'profile_id': 'p1',
    'item_key': 'word:il_reste',
    'is_understood': 1,
    'updated_at': 2000,
  });
  return database;
}

void main() {
  setUpAll(sqfliteFfiInit);

  group('Migrations 16 and 17', () {
    test('are migrations 16 and 17 of the app, 16 changing nothing', () {
      // Assert
      expect(appMigrations[15].version, 16);
      expect(appMigrations[16].version, 17);
    });

    test('upgrade a version 15 database: the class stays', () async {
      // Arrange
      final String inputPath =
          '${await databaseFactoryFfi.getDatabasesPath()}'
          '/migration_017_upgrade_test.db';
      await databaseFactoryFfi.deleteDatabase(inputPath);
      final AppDatabase versionFifteen = _openDatabase(
        appMigrations.take(15).toList(),
        inputPath,
      );
      await (await versionFifteen.database).insert('classroom', _classroomRow);
      await versionFifteen.close();
      // Act
      final AppDatabase upgraded = _openDatabase(
        appMigrations.take(17).toList(),
        inputPath,
      );
      final Database database = await upgraded.database;
      // Assert
      expect(await database.getVersion(), 17);
      expect(await database.query('classroom'), hasLength(1));
      expect(await database.query('class_assessment'), isEmpty);
      await upgraded.close();
      await databaseFactoryFfi.deleteDatabase(inputPath);
    });

    test('keeps one result per pupil and assessment', () async {
      // Arrange
      final AppDatabase appDatabase = _openDatabase(
        appMigrations,
        inMemoryDatabasePath,
      );
      final Database database = await _seed(appDatabase);
      // Act and assert
      await expectLater(
        database.insert('assessment_result', _resultRow('p1')),
        throwsA(isA<DatabaseException>()),
      );
      final List<Map<String, Object?>> actualLevels = await database.query(
        'assessment_level',
      );
      expect(actualLevels.single['level'], isNull);
      await appDatabase.close();
    });

    test('deletes the results of a pupil removed from the class', () async {
      // Arrange
      final AppDatabase appDatabase = _openDatabase(
        appMigrations,
        inMemoryDatabasePath,
      );
      final Database database = await _seed(appDatabase);
      // Act
      await database.delete('profile', where: 'id = ?', whereArgs: ['p1']);
      // Assert
      expect(await database.query('assessment_result'), isEmpty);
      expect(await database.query('assessment_level'), isEmpty);
      expect(await database.query('assessment_word'), isEmpty);
      expect(await database.query('class_assessment'), hasLength(1));
      await appDatabase.close();
    });
  });
}
