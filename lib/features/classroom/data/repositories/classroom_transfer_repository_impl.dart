import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
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
    required this._codec,
    required this._clock,
    required this._readAppVersion,
  });

  /// Extension of the class files, the one of the backups.
  static const String fileExtension = 'kidmatix';

  static const String _fileNamePrefix = 'KidMatix-Classe';
  static const String _logName = 'classroom';
  static final RegExp _unsafeCharacters = RegExp(
    r'[^\p{L}\p{N}]+',
    unicode: true,
  );

  final SharedFileDataSource _files;
  final ClassroomFileCodec _codec;
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
        content: _codec.encode(
          transfer,
          exportedAt: now,
          appVersion: await _readAppVersion(),
        ),
      );
    });
  }

  @override
  Future<DataState<ClassroomTransfer?>> pick() {
    return _guard(() async {
      final String? text = await _files.pickFile();
      return text == null ? null : _codec.decode(text);
    });
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
