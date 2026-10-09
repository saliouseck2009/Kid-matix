import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/profile/data/datasources/active_profile_local_data_source_impl.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_local_data_source_impl.dart';
import 'package:kid_matix/features/profile/data/models/profile_settings_local_model.dart';
import 'package:kid_matix/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/in_memory_local_storage.dart';
import '../helpers/profile_fixtures.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

AppException? _exceptionOf<T>(DataState<T> state) {
  return switch (state) {
    DataSuccess<T>() => null,
    DataFailed<T>(:final AppException exception) => exception,
  };
}

T _dataOf<T>(DataState<T> state) => (state as DataSuccess<T>).data;

void main() {
  late AppDatabase appDatabase;
  late TableChangeBus changeBus;
  late ProfileRepositoryImpl repository;
  final ProfileEntity inputAwa = buildProfile(id: 'p-awa', nickname: 'Awa');
  final ProfileEntity inputLea = buildProfile(
    id: 'p-lea',
    nickname: 'Léa',
  ).copyWith(createdAt: DateTime(2026, 10, 10));

  setUpAll(sqfliteFfiInit);

  setUp(() {
    appDatabase = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      resolvePath: () async => inMemoryDatabasePath,
      migrationRunner: MigrationRunner(migrations: appMigrations),
    );
    changeBus = TableChangeBus();
    repository = ProfileRepositoryImpl(
      profiles: ProfileLocalDataSourceImpl(database: appDatabase),
      activeProfile: ActiveProfileLocalDataSourceImpl(
        storage: InMemoryLocalStorage(),
      ),
      clock: _FixedClock(DateTime(2026, 10, 11)),
      changeBus: changeBus,
    );
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  group('creating and reading', () {
    test('lists the created profiles, oldest first', () async {
      // Arrange
      await repository.createProfile(profile: inputLea);
      await repository.createProfile(profile: inputAwa);
      // Act
      final DataState<List<ProfileEntity>> actualState = await repository
          .getProfiles();
      // Assert
      expect(_dataOf(actualState), <ProfileEntity>[inputAwa, inputLea]);
    });
    test('creates the default settings with the profile', () async {
      // Arrange
      const ProfileSettingsEntity expectedSettings =
          ProfileSettingsEntity.defaults(profileId: 'p-awa');
      // Act
      await repository.createProfile(profile: inputAwa);
      // Assert
      final List<Map<String, Object?>> actualRows =
          await (await appDatabase.database).query('profile_settings');
      expect(
        ProfileSettingsLocalModel.fromJson(actualRows.single).toEntity(),
        expectedSettings,
      );
    });
    test('counts the profiles', () async {
      // Arrange
      await repository.createProfile(profile: inputAwa);
      await repository.createProfile(profile: inputLea);
      // Act
      final DataState<int> actualState = await repository.countProfiles();
      // Assert
      expect(_dataOf(actualState), 2);
    });
    test('reads one profile, or fails when it does not exist', () async {
      // Arrange
      await repository.createProfile(profile: inputAwa);
      // Act
      final DataState<ProfileEntity> actualState = await repository.getProfile(
        profileId: 'p-awa',
      );
      final DataState<ProfileEntity> actualMissingState = await repository
          .getProfile(profileId: 'missing');
      // Assert
      expect(_dataOf(actualState), inputAwa);
      expect(_exceptionOf(actualMissingState), isA<NotFoundException>());
    });
    test('tells the watchers that the profile table changed', () async {
      // Arrange
      final Future<String> actualChange = changeBus
          .watchTable(table: 'profile')
          .first;
      // Act
      await repository.createProfile(profile: inputAwa);
      // Assert
      expect(await actualChange, 'profile');
    });
  });

  group('nickname uniqueness', () {
    setUp(() => repository.createProfile(profile: inputLea));

    test('finds a nickname that differs by case and accents', () async {
      // Act
      final DataState<bool> actualState = await repository.isNicknameTaken(
        nickname: ' LEA ',
      );
      // Assert
      expect(_dataOf(actualState), isTrue);
    });
    test('ignores the excluded profile', () async {
      // Act
      final DataState<bool> actualState = await repository.isNicknameTaken(
        nickname: 'lea',
        excludedProfileId: 'p-lea',
      );
      // Assert
      expect(_dataOf(actualState), isFalse);
    });
    test('refuses to create a profile with a taken nickname', () async {
      // Arrange
      final ProfileEntity inputDuplicate = buildProfile(
        id: 'p-other',
        nickname: 'LEA',
      );
      // Act
      final DataState<ProfileEntity> actualState = await repository
          .createProfile(profile: inputDuplicate);
      // Assert
      expect(_exceptionOf(actualState), isA<ConflictException>());
    });
  });

  group('updating', () {
    setUp(() async {
      await repository.createProfile(profile: inputAwa);
      await repository.createProfile(profile: inputLea);
    });

    test('renames a player', () async {
      // Arrange
      final ProfileEntity expectedProfile = inputAwa.copyWith(
        nickname: 'Awa B',
      );
      // Act
      await repository.updateProfile(profile: expectedProfile);
      // Assert
      final DataState<ProfileEntity> actualState = await repository.getProfile(
        profileId: 'p-awa',
      );
      expect(_dataOf(actualState), expectedProfile);
    });
    test('refuses a nickname another player uses', () async {
      // Act
      final DataState<ProfileEntity> actualState = await repository
          .updateProfile(profile: inputAwa.copyWith(nickname: 'lea'));
      // Assert
      expect(_exceptionOf(actualState), isA<ConflictException>());
    });
    test('fails for a profile that does not exist', () async {
      // Act
      final DataState<ProfileEntity> actualState = await repository
          .updateProfile(profile: inputAwa.copyWith(id: 'missing'));
      // Assert
      expect(_exceptionOf(actualState), isA<NotFoundException>());
    });
  });

  group('deleting', () {
    setUp(() async {
      await repository.createProfile(profile: inputAwa);
      await repository.createProfile(profile: inputLea);
    });

    test('deletes the profile and its settings in cascade', () async {
      // Act
      await repository.deleteProfile(profileId: 'p-awa');
      // Assert
      final Database database = await appDatabase.database;
      final List<Map<String, Object?>> actualSettings = await database.query(
        'profile_settings',
        where: 'profile_id = ?',
        whereArgs: <Object>['p-awa'],
      );
      final DataState<List<ProfileEntity>> actualState = await repository
          .getProfiles();
      expect(actualSettings, isEmpty);
      expect(_dataOf(actualState), <ProfileEntity>[inputLea]);
    });
    test('frees the nickname of the deleted player', () async {
      // Arrange
      await repository.deleteProfile(profileId: 'p-awa');
      // Act
      final DataState<bool> actualState = await repository.isNicknameTaken(
        nickname: 'Awa',
      );
      // Assert
      expect(_dataOf(actualState), isFalse);
    });
    test('forgets the active player when it is deleted', () async {
      // Arrange
      await repository.setActiveProfileId(profileId: 'p-awa');
      // Act
      await repository.deleteProfile(profileId: 'p-awa');
      // Assert
      final DataState<String?> actualState = await repository
          .getActiveProfileId();
      expect(_dataOf(actualState), isNull);
    });
    test('keeps the active player when another one is deleted', () async {
      // Arrange
      await repository.setActiveProfileId(profileId: 'p-lea');
      // Act
      await repository.deleteProfile(profileId: 'p-awa');
      // Assert
      final DataState<String?> actualState = await repository
          .getActiveProfileId();
      expect(_dataOf(actualState), 'p-lea');
    });
    test('fails for a profile that does not exist', () async {
      // Act
      final DataState<void> actualState = await repository.deleteProfile(
        profileId: 'missing',
      );
      // Assert
      expect(_exceptionOf(actualState), isA<NotFoundException>());
    });
  });

  group('active player', () {
    test('is unknown before a player is chosen', () async {
      // Act
      final DataState<String?> actualState = await repository
          .getActiveProfileId();
      // Assert
      expect(_dataOf(actualState), isNull);
    });
    test('is the last chosen player', () async {
      // Arrange
      await repository.createProfile(profile: inputAwa);
      await repository.setActiveProfileId(profileId: 'p-awa');
      // Act
      final DataState<String?> actualState = await repository
          .getActiveProfileId();
      // Assert
      expect(_dataOf(actualState), 'p-awa');
    });
    test('is forgotten when it points to no profile', () async {
      // Arrange
      await repository.setActiveProfileId(profileId: 'gone');
      // Act
      final DataState<String?> actualState = await repository
          .getActiveProfileId();
      // Assert
      expect(_dataOf(actualState), isNull);
    });
  });
}
