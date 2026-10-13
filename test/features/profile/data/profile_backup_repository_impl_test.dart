import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/profile/data/datasources/backup_file_data_source.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_backup_codec.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_backup_local_data_source.dart';
import 'package:kid_matix/features/profile/data/repositories/profile_backup_repository_impl.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_target.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_backup_entity.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';

final class _MockLocal extends Mock implements ProfileBackupLocalDataSource {}

final class _MockFiles extends Mock implements BackupFileDataSource {}

final class _Clock implements Clock {
  @override
  DateTime now() => DateTime(2026, 10, 12, 18);
}

final class _DatabaseFailure extends DatabaseException {
  _DatabaseFailure(super.message, this._code);

  final int? _code;

  @override
  int? getResultCode() => _code;

  @override
  Object? get result => null;
}

const Map<String, Object?> _sections = <String, Object?>{
  'profile': <String, Object?>{
    'profile': <String, Object?>{
      'id': 'p1',
      'nickname': 'Awa Lou',
      'normalized_nickname': 'awa lou',
      'avatar': 'avatar1',
      'color': 'violet',
      'total_xp': 0,
      'level': 3,
      'created_at': 0,
      'updated_at': 0,
    },
  },
};

final ProfileBackupEntity _backup = ProfileBackupEntity(
  nickname: 'Awa',
  level: 1,
  exportedAt: DateTime.utc(2026),
  sections: _sections,
);

const BackupImportTarget _target = BackupImportTarget(
  profileId: 'p9',
  nickname: 'Awa',
  replacesProfile: false,
);

void main() {
  late _MockLocal mockLocal;
  late _MockFiles mockFiles;
  late TableChangeBus changeBus;
  late ProfileBackupRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(_target));

  setUp(() {
    mockLocal = _MockLocal();
    mockFiles = _MockFiles();
    changeBus = TableChangeBus();
    repository = ProfileBackupRepositoryImpl(
      local: mockLocal,
      files: mockFiles,
      codec: const ProfileBackupCodec(),
      clock: _Clock(),
      readAppVersion: () async => '1.2.0',
      changeBus: changeBus,
    );
  });

  void failImportWith(Object error) {
    when(
      () => mockLocal.writeSections(
        sections: any(named: 'sections'),
        target: any(named: 'target'),
      ),
    ).thenThrow(error);
  }

  group('ProfileBackupRepositoryImpl', () {
    test('names the file after the player and the day', () async {
      // Arrange
      when(
        () => mockLocal.readSections(profileId: 'p1'),
      ).thenAnswer((_) async => _sections);
      when(
        () => mockFiles.shareFile(
          fileName: any(named: 'fileName'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => false);
      // Act
      final DataState<bool> actual = await repository.exportProfile(
        profileId: 'p1',
      );
      // Assert
      expect(actual.requireData, isFalse);
      verify(
        () => mockFiles.shareFile(
          fileName: 'KidMatix-Awa-Lou-2026-10-12.kidmatix',
          content: any(named: 'content'),
        ),
      ).called(1);
    });

    test('reads the nickname, level and date of a file picked', () async {
      // Arrange
      when(mockFiles.pickFile).thenAnswer(
        (_) async =>
            '{"format":"kidmatix-profile","version":1,'
            '"exportedAt":"2026-10-12T16:00:00.000Z","appVersion":"1.2.0",'
            '"sections":${'{"profile":{"profile":{"id":"p1","nickname":"Awa",'
                '"normalized_nickname":"awa","avatar":"avatar1",'
                '"color":"violet","total_xp":0,"level":3,"created_at":0,'
                '"updated_at":0}}}'}}',
      );
      // Act
      final ProfileBackupEntity? actual =
          (await repository.pickBackup()).requireData;
      // Assert
      expect(actual?.nickname, 'Awa');
      expect(actual?.level, 3);
      expect(actual?.exportedAt, DateTime.utc(2026, 10, 12, 16));
    });

    test('gives nothing when no file is picked', () async {
      // Arrange
      when(mockFiles.pickFile).thenAnswer((_) async => null);
      // Act
      final DataState<ProfileBackupEntity?> actual = await repository
          .pickBackup();
      // Assert
      expect(actual.requireData, isNull);
    });

    test('refuses a file without its player', () async {
      // Arrange
      when(mockFiles.pickFile).thenAnswer(
        (_) async =>
            '{"format":"kidmatix-profile","version":1,'
            '"exportedAt":"2026-10-12T16:00:00.000Z","appVersion":"1.2.0",'
            '"sections":{}}',
      );
      // Act
      final DataState<ProfileBackupEntity?> actual = await repository
          .pickBackup();
      // Assert
      expect(actual.exceptionOrNull?.code, AppErrorCode.invalidFile);
    });

    test('tells which tables the import wrote', () async {
      // Arrange
      when(
        () => mockLocal.writeSections(
          sections: any(named: 'sections'),
          target: _target,
        ),
      ).thenAnswer((_) async => <String>{'profile', 'mascot'});
      final List<String> actualTables = <String>[];
      changeBus
          .watchTables(tables: <String>{'profile', 'mascot'})
          .listen(actualTables.add);
      // Act
      final DataState<void> actual = await repository.importBackup(
        backup: _backup,
        target: _target,
      );
      await Future<void>.delayed(Duration.zero);
      // Assert
      expect(actual, isA<DataSuccess<void>>());
      expect(actualTables, unorderedEquals(<String>['profile', 'mascot']));
    });

    test('turns the failures of an import into typed errors', () async {
      // Arrange
      final Map<Object, AppErrorCode> inputErrors = <Object, AppErrorCode>{
        const FormatException('bad row'): AppErrorCode.invalidFile,
        _DatabaseFailure(
          'UNIQUE constraint failed: profile.normalized_nickname',
          2067,
        ): AppErrorCode.conflict,
        _DatabaseFailure('FOREIGN KEY constraint failed', 787):
            AppErrorCode.invalidFile,
        _DatabaseFailure('disk I/O error', 10): AppErrorCode.cache,
        _DatabaseFailure('closed', null): AppErrorCode.cache,
        const NotFoundException(): AppErrorCode.notFound,
        PlatformException(code: 'share'): AppErrorCode.unknown,
      };
      // Act and assert
      for (final MapEntry<Object, AppErrorCode> input in inputErrors.entries) {
        failImportWith(input.key);
        final DataState<void> actual = await repository.importBackup(
          backup: _backup,
          target: _target,
        );
        expect(
          actual.exceptionOrNull?.code,
          input.value,
          reason: '${input.key}',
        );
      }
    });
  });
}
