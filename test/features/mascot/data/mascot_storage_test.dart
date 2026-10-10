import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/mascot/data/datasources/mascot_local_data_source_impl.dart';
import 'package:kid_matix/features/mascot/data/models/mascot_local_model.dart';
import 'package:kid_matix/features/mascot/data/repositories/mascot_repository_impl.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_accessory.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_record.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';

final class _Clock implements Clock {
  @override
  DateTime now() => DateTime(2026, 10, 10, 18);
}

Future<AppDatabase> _open(int version, String path) async {
  return AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => path,
    migrationRunner: MigrationRunner(
      migrations: appMigrations.take(version).toList(),
    ),
  );
}

const Map<String, Object?> _profileRow = <String, Object?>{
  'id': 'p1',
  'nickname': 'Awa',
  'normalized_nickname': 'awa',
  'avatar': 'avatar1',
  'color': 'violet',
  'created_at': 0,
  'updated_at': 0,
};

void main() {
  late AppDatabase appDatabase;
  late TableChangeBus changeBus;
  late MascotRepositoryImpl repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = await _open(appMigrations.length, inMemoryDatabasePath);
    await (await appDatabase.database).insert('profile', _profileRow);
    changeBus = TableChangeBus();
    repository = MascotRepositoryImpl(
      mascots: MascotLocalDataSourceImpl(database: appDatabase),
      clock: _Clock(),
      changeBus: changeBus,
    );
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  group('MascotRepositoryImpl', () {
    test('gives the initial mascot before any choice', () async {
      // Act
      final MascotRecord actualMascot = (await repository.getMascot(
        profileId: 'p1',
      )).requireData;
      // Assert
      expect(actualMascot.name, 'Lim');
      expect(actualMascot.worn, isEmpty);
      expect(actualMascot.celebratedStage, 1);
    });
    test('saves the choices and reads them back', () async {
      // Arrange
      final Future<void> actualChange = repository.watchChanges().first;
      // Act
      await repository.saveMascot(
        profileId: 'p1',
        mascot: MascotRecord(
          name: 'Bouboule',
          worn: const <MascotAccessory>[
            MascotAccessory.cap,
            MascotAccessory.cape,
          ],
          celebratedStage: 2,
        ),
      );
      final MascotRecord actualMascot = (await repository.getMascot(
        profileId: 'p1',
      )).requireData;
      // Assert
      expect(actualMascot.name, 'Bouboule');
      expect(actualMascot.worn, <MascotAccessory>[
        MascotAccessory.cap,
        MascotAccessory.cape,
      ]);
      expect(actualMascot.celebratedStage, 2);
      await expectLater(actualChange, completes);
    });
    test('skips an accessory name it does not know', () {
      // Act
      final MascotRecord actualMascot = const MascotLocalModel(
        profileId: 'p1',
        name: 'Lim',
        wornAccessories: 'cap,jetpack',
        celebratedStage: 1,
        updatedAt: 0,
      ).toRecord();
      // Assert
      expect(actualMascot.worn, <MascotAccessory>[MascotAccessory.cap]);
    });
    test('deletes the mascot with its profile', () async {
      // Arrange
      await repository.saveMascot(
        profileId: 'p1',
        mascot: const MascotRecord.initial(),
      );
      final Database database = await appDatabase.database;
      // Act
      await database.delete('profile');
      // Assert
      expect(await database.query('mascot'), isEmpty);
    });
    test('fails to save the mascot of an unknown player', () async {
      // Act
      final AppException? actualException = (await repository.saveMascot(
        profileId: 'unknown',
        mascot: const MascotRecord.initial(),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
    test('fails to read once the database is closed', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final AppException? actualException = (await repository.getMascot(
        profileId: 'p1',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  test('Migration 8 upgrades a version 7 database', () async {
    // Arrange
    final String inputPath =
        '${await databaseFactoryFfi.getDatabasesPath()}'
        '/migration_008_upgrade_test.db';
    await databaseFactoryFfi.deleteDatabase(inputPath);
    final AppDatabase versionSeven = await _open(7, inputPath);
    await (await versionSeven.database).insert('profile', _profileRow);
    await versionSeven.close();
    // Act
    final AppDatabase versionEight = await _open(8, inputPath);
    final Database upgraded = await versionEight.database;
    // Assert
    expect(await upgraded.getVersion(), 8);
    expect(await upgraded.query('profile'), hasLength(1));
    expect(await upgraded.query('mascot'), isEmpty);
    await versionEight.close();
    await databaseFactoryFfi.deleteDatabase(inputPath);
  });
}
