import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Map<String, Object?> _profileRow(String id, String classroomId, int at) {
  return <String, Object?>{
    'id': id,
    'nickname': 'Awa $id',
    'normalized_nickname': 'awa $id',
    'avatar': 'avatar1',
    'color': 'violet',
    'created_at': at,
    'updated_at': at,
    'classroom_id': classroomId,
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

  test('is migration 18 of the app', () {
    // Assert
    expect(appMigrations[17].version, 18);
  });

  test('numbers the pupils already in a class, in the class order', () async {
    // Arrange
    final String inputPath =
        '${await databaseFactoryFfi.getDatabasesPath()}'
        '/migration_018_upgrade_test.db';
    await databaseFactoryFfi.deleteDatabase(inputPath);
    final AppDatabase versionSeventeen = _openDatabase(
      appMigrations.take(17).toList(),
      inputPath,
    );
    final Database old = await versionSeventeen.database;
    await old.insert('classroom', _classroomRow('c1'));
    await old.insert('classroom', _classroomRow('c2'));
    await old.insert('profile', _profileRow('b', 'c1', 1));
    await old.insert('profile', _profileRow('a', 'c1', 1));
    await old.insert('profile', _profileRow('c', 'c1', 0));
    await old.insert('profile', _profileRow('d', 'c2', 5));
    await versionSeventeen.close();
    // Act
    final AppDatabase upgraded = _openDatabase(
      appMigrations.take(18).toList(),
      inputPath,
    );
    final Database database = await upgraded.database;
    // Assert
    final List<Map<String, Object?>> actual = await database.query(
      'class_pupil_number',
      orderBy: 'classroom_id, number',
    );
    expect(actual.map((Map<String, Object?> r) => r['profile_id']), <String>[
      'c',
      'a',
      'b',
      'd',
    ]);
    expect(actual.map((Map<String, Object?> r) => r['number']), <int>[
      1,
      2,
      3,
      1,
    ]);
    await expectLater(
      database.insert('class_pupil_number', <String, Object?>{
        'classroom_id': 'c1',
        'profile_id': 'z',
        'number': 1,
        'updated_at': 0,
      }),
      throwsA(isA<DatabaseException>()),
    );
    await upgraded.close();
    await databaseFactoryFfi.deleteDatabase(inputPath);
  });
}
