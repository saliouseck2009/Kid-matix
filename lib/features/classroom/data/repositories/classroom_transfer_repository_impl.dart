import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/core/storage/shared_file_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_file_codec.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_transfer_repository.dart';

/// [ClassroomTransferRepository] over the share sheet and the file
/// picker of the system.
final class ClassroomTransferRepositoryImpl
    implements ClassroomTransferRepository {
  /// Creates the repository; [readAppVersion] gives the version written
  /// in the files.
  const ClassroomTransferRepositoryImpl({
    required this._files,
    required this._storage,
    required this._clock,
    required this._readAppVersion,
  });

  /// Preference key of the last export of a class, before its id.
  static const String lastExportKeyPrefix = 'class_last_export_';

  /// Extension of the class files, the one of the backups.
  static const String fileExtension = 'kidmatix';

  static const String _fileNamePrefix = 'KidMatix-Classe';
  static const String _logName = 'classroom';
  static final RegExp _unsafeCharacters = RegExp(
    r'[^\p{L}\p{N}]+',
    unicode: true,
  );

  final SharedFileDataSource _files;
  final LocalStorage _storage;
  final Clock _clock;
  final Future<String> Function() _readAppVersion;

  /// Name such as `KidMatix-Classe-CE1-B-2026-10-21.kidmatix`.
  static String fileNameOf(String classroomName, DateTime day) {
    final String name = classroomName
        .replaceAll(_unsafeCharacters, '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final String date = day.toIso8601String().substring(0, 10);
    return '$_fileNamePrefix-$name-$date.$fileExtension';
  }

  @override
  Future<DataState<bool>> share({required ClassroomTransfer transfer}) {
    return _guard(() async {
      final DateTime now = _clock.now();
      return _files.shareFile(
        fileName: fileNameOf(transfer.classroom.name, now),
        // Thousands of answers: written away from the screen's isolate.
        content: await compute(ClassroomFileCodec.encodeContent, (
          transfer: transfer,
          exportedAt: now,
          appVersion: await _readAppVersion(),
        )),
      );
    });
  }

  @override
  Future<DataState<ClassroomTransfer?>> pick() {
    return _guard(() async {
      final String? text = await _files.pickFile();
      if (text == null) return null;
      return compute(ClassroomFileCodec.decodeText, text);
    });
  }

  @override
  Future<DataState<DateTime?>> readLastExport({required String classroomId}) {
    return _guard(() async {
      final String? stored = await _storage.readString(
        key: '$lastExportKeyPrefix$classroomId',
      );
      return stored == null ? null : DateTime.tryParse(stored);
    });
  }

  @override
  Future<DataState<void>> saveLastExport({
    required String classroomId,
    required DateTime exportedAt,
  }) {
    return _guard(
      () => _storage.writeString(
        key: '$lastExportKeyPrefix$classroomId',
        value: exportedAt.toIso8601String(),
      ),
    );
  }

  Future<DataState<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return DataSuccess<T>(await action());
    } on AppException catch (exception) {
      return DataFailed<T>(exception);
    } on Exception catch (error, stackTrace) {
      log(
        'Class file failure',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<T>(UnknownException(message: error.toString()));
    }
  }
}
