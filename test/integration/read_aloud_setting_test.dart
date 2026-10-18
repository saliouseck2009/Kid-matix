import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/profile/data/datasources/active_profile_local_data_source_impl.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_local_data_source_impl.dart';
import 'package:kid_matix/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/services/player_settings_service_impl.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/nickname_checker.dart';
import 'package:kid_matix/features/profile/domain/usecases/update_settings_use_case.dart';
import 'package:kid_matix/features/quiz/domain/entities/read_aloud_mode.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_read_aloud_mode_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_mode_params.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/data_state_test_extension.dart';
import '../helpers/fake_speech_service.dart';
import '../helpers/in_memory_local_storage.dart';

final class _Clock implements Clock {
  @override
  DateTime now() => DateTime(2026, 10, 18, 10);
}

/// Hands out `p-1`, `p-2`... as the players are created.
final class _CountingIds implements IdGenerator {
  int _count = 0;

  @override
  String generateId() => 'p-${++_count}';
}

void main() {
  late AppDatabase appDatabase;
  late CreateProfileUseCase createProfile;
  late UpdateSettingsUseCase updateSettings;
  late PlayerSettingsServiceImpl settings;
  late FakeSpeechService speech;

  setUpAll(sqfliteFfiInit);

  setUp(() {
    appDatabase = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      resolvePath: () async => inMemoryDatabasePath,
      migrationRunner: MigrationRunner(migrations: appMigrations),
    );
    final ProfileRepositoryImpl repository = ProfileRepositoryImpl(
      profiles: ProfileLocalDataSourceImpl(database: appDatabase),
      activeProfile: ActiveProfileLocalDataSourceImpl(
        storage: InMemoryLocalStorage(),
      ),
      clock: _Clock(),
      changeBus: TableChangeBus(),
    );
    createProfile = CreateProfileUseCase(
      repository: repository,
      nicknameChecker: NicknameChecker(repository: repository),
      idGenerator: _CountingIds(),
      clock: _Clock(),
    );
    updateSettings = UpdateSettingsUseCase(repository: repository);
    settings = PlayerSettingsServiceImpl(repository: repository);
    speech = FakeSpeechService();
  });

  tearDown(() => appDatabase.close());

  Future<String> create(String nickname, {bool readsAloud = false}) async {
    final DataState<ProfileEntity> created = await createProfile(
      params: CreateProfileParams(
        nickname: nickname,
        avatar: ProfileAvatar.avatar1,
        color: ProfileColor.violet,
        isReadAloudEnabled: readsAloud,
      ),
    );
    return created.requireData.id;
  }

  Future<ReadAloudMode> modeOf(String profileId) {
    return GetReadAloudModeUseCase(speech: speech, settings: settings)(
      params: ReadAloudModeParams(profileId: profileId, languageCode: 'fr'),
    );
  }

  group('The reading aloud setting of each player', () {
    test('is off for a player created without the offer', () async {
      // Arrange
      final String inputId = await create('Awa');
      // Act
      final ReadAloudMode actualMode = await modeOf(inputId);
      // Assert
      expect(
        (await settings.readReadAloudEnabled(
          profileId: inputId,
        )).requireData,
        isFalse,
      );
      expect(actualMode, ReadAloudMode.onRequest);
    });
    test('is on for a player who accepted the offer, and only them', () async {
      // Arrange
      final String inputAwa = await create('Awa', readsAloud: true);
      final String inputMoussa = await create('Moussa');
      // Act
      final ReadAloudMode actualAwa = await modeOf(inputAwa);
      final ReadAloudMode actualMoussa = await modeOf(inputMoussa);
      // Assert
      expect(actualAwa, ReadAloudMode.automatic);
      expect(actualMoussa, ReadAloudMode.onRequest);
    });
    test(
      'changes for one player in the settings, not for the others',
      () async {
        // Arrange
        final String inputAwa = await create('Awa');
        final String inputMoussa = await create('Moussa');
        final ProfileSettingsEntity inputSettings =
            ProfileSettingsEntity.defaults(profileId: inputMoussa);
        // Act
        await updateSettings(
          params: inputSettings.copyWith(isReadAloudEnabled: true),
        );
        // Assert
        expect(await modeOf(inputMoussa), ReadAloudMode.automatic);
        expect(await modeOf(inputAwa), ReadAloudMode.onRequest);
      },
    );
    test('reads nothing for anyone when the phone has no voice', () async {
      // Arrange
      final String inputAwa = await create('Awa', readsAloud: true);
      speech.hasVoice = false;
      // Act
      final ReadAloudMode actualMode = await modeOf(inputAwa);
      // Assert
      expect(actualMode, ReadAloudMode.unavailable);
    });
  });
}
