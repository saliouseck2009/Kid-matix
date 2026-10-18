import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_choice.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_preview_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_backup_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/import_backup_params.dart';
import 'package:kid_matix/features/profile/presentation/bloc/backup_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/backup_state.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/profile_fixtures.dart';

final ProfileBackupEntity _backup = ProfileBackupEntity(
  nickname: 'Awa',
  level: 5,
  exportedAt: DateTime.utc(2026, 10, 12),
  sections: const <String, Object?>{},
);

final BackupPreviewEntity _free = BackupPreviewEntity(backup: _backup);

final BackupPreviewEntity _taken = BackupPreviewEntity(
  backup: _backup,
  conflictingProfile: buildProfile(id: 'p2'),
);

void main() {
  late MockExportProfileUseCase mockExport;
  late MockPickBackupUseCase mockPick;
  late MockImportBackupUseCase mockImport;

  setUpAll(() {
    registerFallbackValue(
      ImportBackupParams(backup: _backup, choice: const ImportAsNewPlayer()),
    );
  });

  setUp(() {
    mockExport = MockExportProfileUseCase();
    mockPick = MockPickBackupUseCase();
    mockImport = MockImportBackupUseCase();
    when(
      () => mockImport.call(params: any(named: 'params')),
    ).thenAnswer((_) async => const DataSuccess<String>('Awa'));
  });

  BackupCubit buildCubit() {
    return BackupCubit(
      profileId: 'p1',
      useCases: buildBackupUseCases(
        exportProfile: mockExport,
        pickBackup: mockPick,
        importBackup: mockImport,
      ),
    );
  }

  BackupImportChoice importedChoice() {
    return (verify(
              () => mockImport.call(params: captureAny(named: 'params')),
            ).captured.single
            as ImportBackupParams)
        .choice;
  }

  group('BackupCubit', () {
    blocTest<BackupCubit, BackupState>(
      'tells when the file was shared',
      setUp: () => when(
        () => mockExport.call(params: 'p1'),
      ).thenAnswer((_) async => const DataSuccess<bool>(true)),
      build: buildCubit,
      act: (BackupCubit cubit) => cubit.exportProfile(),
      expect: () => <Matcher>[isA<BackupWorking>(), isA<BackupExported>()],
    );

    blocTest<BackupCubit, BackupState>(
      'goes back quietly when the share sheet is closed',
      setUp: () => when(
        () => mockExport.call(params: 'p1'),
      ).thenAnswer((_) async => const DataSuccess<bool>(false)),
      build: buildCubit,
      act: (BackupCubit cubit) => cubit.exportProfile(),
      expect: () => <Matcher>[isA<BackupWorking>(), isA<BackupIdle>()],
    );

    blocTest<BackupCubit, BackupState>(
      'reports a failed export',
      setUp: () => when(
        () => mockExport.call(params: 'p1'),
      ).thenAnswer((_) async => const DataFailed<bool>(CacheException())),
      build: buildCubit,
      act: (BackupCubit cubit) => cubit.exportProfile(),
      expect: () => <Matcher>[
        isA<BackupWorking>(),
        isA<BackupFailed>().having(
          (BackupFailed state) => state.errorCode,
          'errorCode',
          AppErrorCode.cache,
        ),
      ],
    );

    blocTest<BackupCubit, BackupState>(
      'imports at once a file whose nickname is free',
      setUp: () => when(
        mockPick.call,
      ).thenAnswer((_) async => DataSuccess<BackupPreviewEntity?>(_free)),
      build: buildCubit,
      act: (BackupCubit cubit) => cubit.pickBackup(),
      expect: () => <Matcher>[
        isA<BackupWorking>(),
        isA<BackupImported>()
            .having((BackupImported state) => state.nickname, 'nickname', 'Awa')
            .having(
              (BackupImported state) => state.wasReplaced,
              'wasReplaced',
              isFalse,
            ),
      ],
      verify: (_) => expect(importedChoice(), const ImportAsNewPlayer()),
    );

    blocTest<BackupCubit, BackupState>(
      'goes back quietly when no file is picked',
      setUp: () => when(
        mockPick.call,
      ).thenAnswer((_) async => const DataSuccess<BackupPreviewEntity?>(null)),
      build: buildCubit,
      act: (BackupCubit cubit) => cubit.pickBackup(),
      expect: () => <Matcher>[isA<BackupWorking>(), isA<BackupIdle>()],
    );

    blocTest<BackupCubit, BackupState>(
      'refuses a damaged file',
      setUp: () => when(mockPick.call).thenAnswer(
        (_) async =>
            const DataFailed<BackupPreviewEntity?>(InvalidFileException()),
      ),
      build: buildCubit,
      act: (BackupCubit cubit) => cubit.pickBackup(),
      expect: () => <Matcher>[
        isA<BackupWorking>(),
        isA<BackupFailed>().having(
          (BackupFailed state) => state.errorCode,
          'errorCode',
          AppErrorCode.invalidFile,
        ),
      ],
    );

    blocTest<BackupCubit, BackupState>(
      'asks how to settle a nickname already used, then replaces',
      setUp: () => when(
        mockPick.call,
      ).thenAnswer((_) async => DataSuccess<BackupPreviewEntity?>(_taken)),
      build: buildCubit,
      act: (BackupCubit cubit) async {
        await cubit.pickBackup();
        await cubit.replacePlayer();
      },
      expect: () => <Matcher>[
        isA<BackupWorking>(),
        isA<BackupConflict>(),
        isA<BackupWorking>(),
        isA<BackupImported>().having(
          (BackupImported state) => state.wasReplaced,
          'wasReplaced',
          isTrue,
        ),
      ],
      verify: (_) =>
          expect(importedChoice(), const ReplacePlayer(profileId: 'p2')),
    );

    blocTest<BackupCubit, BackupState>(
      'asks again when the new nickname is refused',
      setUp: () => when(
        () => mockImport.call(params: any(named: 'params')),
      ).thenAnswer((_) async => const DataFailed<String>(ConflictException())),
      build: buildCubit,
      seed: () => BackupConflict(preview: _taken),
      act: (BackupCubit cubit) => cubit.renamePlayer('Lina'),
      expect: () => <Matcher>[
        isA<BackupWorking>(),
        isA<BackupRenameRefused>()
            .having(
              (BackupRenameRefused state) => state.nickname,
              'nickname',
              'Lina',
            )
            .having(
              (BackupRenameRefused state) => state.errorCode,
              'errorCode',
              AppErrorCode.conflict,
            ),
      ],
    );

    blocTest<BackupCubit, BackupState>(
      'reports a full phone when renaming',
      setUp: () =>
          when(
            () => mockImport.call(params: any(named: 'params')),
          ).thenAnswer(
            (_) async => const DataFailed<String>(LimitReachedException()),
          ),
      build: buildCubit,
      seed: () => BackupRenameRefused(
        preview: _taken,
        nickname: 'Lina',
        errorCode: AppErrorCode.conflict,
      ),
      act: (BackupCubit cubit) => cubit.renamePlayer('Lou'),
      expect: () => <Matcher>[
        isA<BackupWorking>(),
        isA<BackupFailed>().having(
          (BackupFailed state) => state.errorCode,
          'errorCode',
          AppErrorCode.limitReached,
        ),
      ],
    );

    blocTest<BackupCubit, BackupState>(
      'does nothing without a file picked, and gives up on cancel',
      build: buildCubit,
      seed: () => BackupConflict(preview: _taken),
      act: (BackupCubit cubit) async {
        cubit.cancel();
        await cubit.replacePlayer();
        await cubit.renamePlayer('Lina');
      },
      expect: () => <Matcher>[isA<BackupIdle>()],
    );

    blocTest<BackupCubit, BackupState>(
      'ignores a second tap while working',
      build: buildCubit,
      seed: () => const BackupWorking(),
      act: (BackupCubit cubit) async {
        await cubit.exportProfile();
        await cubit.pickBackup();
      },
      expect: () => <BackupState>[],
    );
  });
}
