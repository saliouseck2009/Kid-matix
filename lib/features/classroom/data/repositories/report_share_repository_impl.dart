import 'dart:developer';

import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/storage/shared_file_data_source.dart';
import 'package:kid_matix/features/classroom/domain/repositories/report_share_repository.dart';

/// [ReportShareRepository] over the share sheet of the system.
final class ReportShareRepositoryImpl implements ReportShareRepository {
  /// Creates the repository.
  const ReportShareRepositoryImpl({required this._files});

  final SharedFileDataSource _files;

  @override
  Future<DataState<bool>> share({required List<SharedFile> files}) async {
    try {
      return DataSuccess<bool>(await _files.shareFiles(files: files));
    } on Exception catch (error, stackTrace) {
      log(
        'Files not shared',
        name: 'classroom',
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<bool>(UnknownException(message: error.toString()));
    }
  }

  @override
  Future<DataState<List<int>?>> pick() async {
    try {
      return DataSuccess<List<int>?>(await _files.pickBytes());
    } on AppException catch (exception) {
      return DataFailed<List<int>?>(exception);
    } on Exception catch (error, stackTrace) {
      log(
        'File not picked',
        name: 'classroom',
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<List<int>?>(
        UnknownException(message: error.toString()),
      );
    }
  }
}
