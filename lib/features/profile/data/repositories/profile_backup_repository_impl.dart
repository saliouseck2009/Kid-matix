import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/profile/data/datasources/app_version_reader.dart';
import 'package:kid_matix/core/storage/shared_file_data_source.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_backup_codec.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_backup_local_data_source.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_backup_section.dart';
import 'package:kid_matix/features/profile/data/models/profile_backup_file_model.dart';
import 'package:kid_matix/features/profile/data/models/profile_local_model.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_target.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_backup_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_backup_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [ProfileBackupRepository] over the local database and the files of
/// the system. Nothing leaves the phone unless the player shares the file.
final class ProfileBackupRepositoryImpl implements ProfileBackupRepository {
  /// Creates the repository.
  const ProfileBackupRepositoryImpl({
    required this._local,
    required this._files,
    required this._codec,
    required this._clock,
    required this._readAppVersion,
    required this._changeBus,
  });

  /// Extension of a backup file.
  static const String fileExtension = 'kidmatix';

  static const String _logName = 'backup';
  static const String _fileNamePrefix = 'KidMatix';
  static const int _constraintResultCode = 19;
  static const int _primaryResultCodeMask = 0xff;
  static final RegExp _spaces = RegExp(r'\s+');

  final ProfileBackupLocalDataSource _local;
  final SharedFileDataSource _files;
  final ProfileBackupCodec _codec;
  final Clock _clock;
  final AppVersionReader _readAppVersion;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<bool>> exportProfile({required String profileId}) {
    return _guard(() async {
      final Map<String, Object?> sections = await _local.readSections(
        profileId: profileId,
      );
      final DateTime now = _clock.now();
      final String content = _codec.encode(
        ProfileBackupFileModel(
          format: ProfileBackupFileModel.formatName,
          version: ProfileBackupFileModel.currentVersion,
          exportedAt: now.toUtc().toIso8601String(),
          appVersion: await _readAppVersion(),
          sections: sections,
        ),
      );
      return _files.shareFile(
        fileName: _fileNameOf(ProfileBackupSection.readProfile(sections), now),
        content: content,
      );
    });
  }

  @override
  Future<DataState<ProfileBackupEntity?>> pickBackup() {
    return _guard(() async {
      final String? text = await _files.pickFile();
      if (text == null) return null;
      final ProfileBackupFileModel file = _codec.decode(text);
      final ProfileLocalModel profile = ProfileBackupSection.readProfile(
        file.sections,
      );
      return ProfileBackupEntity(
        nickname: profile.nickname,
        level: profile.level,
        exportedAt: DateTime.parse(file.exportedAt),
        sections: file.sections,
      );
    });
  }

  @override
  Future<DataState<void>> importBackup({
    required ProfileBackupEntity backup,
    required BackupImportTarget target,
  }) {
    return _guard(() async {
      final Set<String> tables = await _local.writeSections(
        sections: backup.sections,
        target: target,
      );
      for (final String table in tables) {
        _changeBus.notifyChanged(table: table);
      }
    });
  }

  /// Name such as `KidMatix-Awa-2026-10-12.kidmatix`.
  String _fileNameOf(ProfileLocalModel profile, DateTime now) {
    final String nickname = profile.nickname.trim().replaceAll(_spaces, '-');
    final String day = now.toIso8601String().substring(0, 10);
    return '$_fileNamePrefix-$nickname-$day.$fileExtension';
  }

  /// Runs [action] and turns its outcome or its failure into a [DataState].
  Future<DataState<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return DataSuccess<T>(await action());
    } on AppException catch (exception) {
      return DataFailed<T>(exception);
    } on FormatException catch (error) {
      return DataFailed<T>(InvalidFileException(message: error.message));
    } on DatabaseException catch (error, stackTrace) {
      log(
        'Database failure',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<T>(_exceptionOf(error));
    } on Object catch (error, stackTrace) {
      log(
        'Unexpected failure',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<T>(UnknownException(message: error.toString()));
    }
  }

  /// A nickname taken meanwhile is a conflict; another broken constraint
  /// while importing means rows of the file do not fit together: the file
  /// is damaged.
  AppException _exceptionOf(DatabaseException error) {
    if (error.isUniqueConstraintError('profile.normalized_nickname')) {
      return const ConflictException(message: 'Nickname already taken.');
    }
    final int? code = error.getResultCode();
    if (code != null &&
        code & _primaryResultCodeMask == _constraintResultCode) {
      return InvalidFileException(message: error.toString());
    }
    return CacheException(message: error.toString());
  }
}
