import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_choice.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_target.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_preview_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_backup_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_limits.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_backup_repository.dart';
import 'package:kid_matix/features/profile/domain/usecases/export_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/import_backup_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/import_backup_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/nickname_checker.dart';
import 'package:kid_matix/features/profile/domain/usecases/pick_backup_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/data_state_test_extension.dart';
import '../../helpers/profile_fixtures.dart';

final class _MockBackupRepository extends Mock
    implements ProfileBackupRepository {}

final class _MockIdGenerator extends Mock implements IdGenerator {}

final ProfileBackupEntity _backup = ProfileBackupEntity(
  nickname: 'Awa',
  level: 5,
  exportedAt: DateTime.utc(2026, 10, 12),
  sections: const <String, Object?>{},
);

void main() {
  late _MockBackupRepository mockBackups;
  late MockProfileRepository mockProfiles;
  late ImportBackupUseCase importUseCase;

  setUpAll(() {
    registerFallbackValue(_backup);
    registerFallbackValue(
      const BackupImportTarget(
        profileId: '',
        nickname: '',
        replacesProfile: false,
      ),
    );
  });

  setUp(() {
    mockBackups = _MockBackupRepository();
    mockProfiles = MockProfileRepository();
    final _MockIdGenerator mockIds = _MockIdGenerator();
    when(mockIds.generateId).thenReturn('new-id');
    when(
      mockProfiles.countFreeProfiles,
    ).thenAnswer((_) async => const DataSuccess<int>(2));
    when(
      () => mockProfiles.isNicknameTaken(
        nickname: any(named: 'nickname'),
        excludedProfileId: any(named: 'excludedProfileId'),
      ),
    ).thenAnswer((_) async => const DataSuccess<bool>(false));
    when(
      () => mockBackups.importBackup(
        backup: any(named: 'backup'),
        target: any(named: 'target'),
      ),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
    importUseCase = ImportBackupUseCase(
      backups: mockBackups,
      profiles: mockProfiles,
      nicknameChecker: NicknameChecker(repository: mockProfiles),
      idGenerator: mockIds,
    );
  });

  BackupImportTarget importedTarget() {
    return verify(
          () => mockBackups.importBackup(
            backup: any(named: 'backup'),
            target: captureAny(named: 'target'),
          ),
        ).captured.single
        as BackupImportTarget;
  }

  group('ExportProfileUseCase', () {
    test('shares the backup of the player', () async {
      // Arrange
      when(
        () => mockBackups.exportProfile(profileId: 'p1'),
      ).thenAnswer((_) async => const DataSuccess<bool>(true));
      // Act
      final DataState<bool> actual = await ExportProfileUseCase(
        repository: mockBackups,
      )(params: 'p1');
      // Assert
      expect(actual.requireData, isTrue);
    });
  });

  group('PickBackupUseCase', () {
    late PickBackupUseCase pickUseCase;

    setUp(() {
      pickUseCase = PickBackupUseCase(
        backups: mockBackups,
        profiles: mockProfiles,
      );
      when(() => mockProfiles.getProfiles()).thenAnswer(
        (_) async => DataSuccess<List<ProfileEntity>>(<ProfileEntity>[
          buildProfile(id: 'p1', nickname: 'Bob'),
          buildProfile(id: 'p2', nickname: 'ÀWA'),
        ]),
      );
    });

    test('finds the player who already uses the nickname', () async {
      // Arrange
      when(
        mockBackups.pickBackup,
      ).thenAnswer((_) async => DataSuccess<ProfileBackupEntity?>(_backup));
      // Act
      final BackupPreviewEntity? actual = (await pickUseCase()).requireData;
      // Assert
      expect(actual?.backup, _backup);
      expect(actual?.conflictingProfile?.id, 'p2');
      expect(actual?.hasConflict, isTrue);
    });

    test('finds no conflict for a free nickname', () async {
      // Arrange
      when(mockBackups.pickBackup).thenAnswer(
        (_) async => DataSuccess<ProfileBackupEntity?>(
          _backup.copyWith(nickname: 'Lina'),
        ),
      );
      // Act
      final BackupPreviewEntity? actual = (await pickUseCase()).requireData;
      // Assert
      expect(actual?.hasConflict, isFalse);
    });

    test('gives nothing when no file is picked', () async {
      // Arrange
      when(
        mockBackups.pickBackup,
      ).thenAnswer((_) async => const DataSuccess<ProfileBackupEntity?>(null));
      // Act
      final DataState<BackupPreviewEntity?> actual = await pickUseCase();
      // Assert
      expect(actual.requireData, isNull);
      verifyNever(() => mockProfiles.getProfiles());
    });

    test('refuses a file whose nickname breaks the rules', () async {
      // Arrange
      when(mockBackups.pickBackup).thenAnswer(
        (_) async =>
            DataSuccess<ProfileBackupEntity?>(_backup.copyWith(nickname: 'A')),
      );
      // Act
      final DataState<BackupPreviewEntity?> actual = await pickUseCase();
      // Assert
      expect(actual.exceptionOrNull?.code, AppErrorCode.invalidFile);
    });

    test('passes on a failure of the file or of the players', () async {
      // Arrange
      when(mockBackups.pickBackup).thenAnswer(
        (_) async => const DataFailed<ProfileBackupEntity?>(
          UnsupportedVersionException(),
        ),
      );
      // Act
      final DataState<BackupPreviewEntity?> actualFile = await pickUseCase();
      when(
        mockBackups.pickBackup,
      ).thenAnswer((_) async => DataSuccess<ProfileBackupEntity?>(_backup));
      when(() => mockProfiles.getProfiles()).thenAnswer(
        (_) async => const DataFailed<List<ProfileEntity>>(CacheException()),
      );
      final DataState<BackupPreviewEntity?> actualPlayers = await pickUseCase();
      // Assert
      expect(actualFile.exceptionOrNull?.code, AppErrorCode.unsupportedVersion);
      expect(actualPlayers.exceptionOrNull?.code, AppErrorCode.cache);
    });
  });

  group('ImportBackupUseCase', () {
    test('imports a new player under a new identifier', () async {
      // Act
      final DataState<String> actual = await importUseCase(
        params: ImportBackupParams(
          backup: _backup,
          choice: const ImportAsNewPlayer(),
        ),
      );
      // Assert
      expect(actual.requireData, 'Awa');
      expect(
        importedTarget(),
        const BackupImportTarget(
          profileId: 'new-id',
          nickname: 'Awa',
          replacesProfile: false,
        ),
      );
    });

    test('replaces a player, keeping their identifier', () async {
      // Act
      await importUseCase(
        params: ImportBackupParams(
          backup: _backup,
          choice: const ReplacePlayer(profileId: 'p2'),
        ),
      );
      // Assert
      expect(
        importedTarget(),
        const BackupImportTarget(
          profileId: 'p2',
          nickname: 'Awa',
          replacesProfile: true,
        ),
      );
      verify(
        () => mockProfiles.isNicknameTaken(
          nickname: 'Awa',
          excludedProfileId: 'p2',
        ),
      ).called(1);
      verifyNever(mockProfiles.countFreeProfiles);
    });

    test('imports under the nickname typed, cleaned', () async {
      // Act
      final DataState<String> actual = await importUseCase(
        params: ImportBackupParams(
          backup: _backup,
          choice: const RenamePlayer(nickname: '  Awa   Deux '),
        ),
      );
      // Assert
      expect(actual.requireData, 'Awa Deux');
      expect(importedTarget().nickname, 'Awa Deux');
    });

    test('refuses a nickname taken, invalid, or a full phone', () async {
      // Arrange
      when(
        () => mockProfiles.isNicknameTaken(
          nickname: 'Lina',
          excludedProfileId: any(named: 'excludedProfileId'),
        ),
      ).thenAnswer((_) async => const DataSuccess<bool>(true));
      // Act
      final DataState<String> actualTaken = await importUseCase(
        params: ImportBackupParams(
          backup: _backup,
          choice: const RenamePlayer(nickname: 'Lina'),
        ),
      );
      final DataState<String> actualInvalid = await importUseCase(
        params: ImportBackupParams(
          backup: _backup,
          choice: const RenamePlayer(nickname: 'L!'),
        ),
      );
      when(mockProfiles.countFreeProfiles).thenAnswer(
        (_) async => const DataSuccess<int>(ProfileLimits.maxProfiles),
      );
      final DataState<String> actualFull = await importUseCase(
        params: ImportBackupParams(
          backup: _backup,
          choice: const ImportAsNewPlayer(),
        ),
      );
      // Assert
      expect(actualTaken.exceptionOrNull?.code, AppErrorCode.conflict);
      expect(actualInvalid.exceptionOrNull?.code, AppErrorCode.validation);
      expect(actualFull.exceptionOrNull?.code, AppErrorCode.limitReached);
      verifyNever(
        () => mockBackups.importBackup(
          backup: any(named: 'backup'),
          target: any(named: 'target'),
        ),
      );
    });

    test('passes on a failure of the import', () async {
      // Arrange
      when(
        () => mockBackups.importBackup(
          backup: any(named: 'backup'),
          target: any(named: 'target'),
        ),
      ).thenAnswer(
        (_) async => const DataFailed<void>(InvalidFileException()),
      );
      when(
        mockProfiles.countFreeProfiles,
      ).thenAnswer((_) async => const DataFailed<int>(CacheException()));
      // Act
      final DataState<String> actualCount = await importUseCase(
        params: ImportBackupParams(
          backup: _backup,
          choice: const ImportAsNewPlayer(),
        ),
      );
      final DataState<String> actualImport = await importUseCase(
        params: ImportBackupParams(
          backup: _backup,
          choice: const ReplacePlayer(profileId: 'p2'),
        ),
      );
      // Assert
      expect(actualCount.exceptionOrNull?.code, AppErrorCode.cache);
      expect(actualImport.exceptionOrNull?.code, AppErrorCode.invalidFile);
    });
  });

  group('Backup entities', () {
    test('compare by value', () {
      // Arrange
      final ProfileBackupEntity inputCopy = _backup.copyWith();
      final BackupPreviewEntity inputPreview = BackupPreviewEntity(
        backup: _backup,
      );
      const BackupImportTarget inputTarget = BackupImportTarget(
        profileId: 'p',
        nickname: 'Awa',
        replacesProfile: false,
      );
      // Assert
      expect(inputCopy, _backup);
      expect(inputCopy.hashCode, _backup.hashCode);
      expect(inputPreview.copyWith(), inputPreview);
      expect(inputPreview.copyWith().hashCode, inputPreview.hashCode);
      expect(inputTarget.copyWith(), inputTarget);
      expect(inputTarget.copyWith(replacesProfile: true), isNot(inputTarget));
      expect(inputTarget.copyWith().hashCode, inputTarget.hashCode);
      expect(const ImportAsNewPlayer(), const ImportAsNewPlayer());
      expect(
        const ImportAsNewPlayer().hashCode,
        const ImportAsNewPlayer().hashCode,
      );
      expect(
        const ReplacePlayer(profileId: 'p').hashCode,
        const ReplacePlayer(profileId: 'p').hashCode,
      );
      expect(
        const RenamePlayer(nickname: 'A').hashCode,
        const RenamePlayer(nickname: 'A').hashCode,
      );
      expect(
        ImportBackupParams(backup: _backup, choice: const ImportAsNewPlayer()),
        ImportBackupParams(backup: _backup, choice: const ImportAsNewPlayer()),
      );
      expect(
        ImportBackupParams(
          backup: _backup,
          choice: const ImportAsNewPlayer(),
        ).hashCode,
        ImportBackupParams(
          backup: _backup,
          choice: const ImportAsNewPlayer(),
        ).hashCode,
      );
    });
  });
}
