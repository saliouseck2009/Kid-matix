import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:sqflite/sqflite.dart';

/// Runs a storage [action] of the class mode and turns its outcome or
/// its failure into a [DataState], logging database failures.
Future<DataState<T>> guardClassroomStorage<T>(
  Future<T> Function() action,
) async {
  try {
    return DataSuccess<T>(await action());
  } on AppException catch (exception) {
    return DataFailed<T>(exception);
  } on DatabaseException catch (error, stackTrace) {
    log(
      'Database failure',
      name: 'classroom',
      error: error,
      stackTrace: stackTrace,
    );
    return DataFailed<T>(CacheException(message: error.toString()));
  }
}
