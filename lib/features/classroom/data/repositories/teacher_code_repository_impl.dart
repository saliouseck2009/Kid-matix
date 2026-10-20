import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/classroom/domain/repositories/teacher_code_repository.dart';

/// [TeacherCodeRepository] over the device preferences.
///
/// The code is a lock against curious children, not a secret: it keeps
/// no personal data behind it, so it lives with the preferences, not in
/// a secure storage.
final class TeacherCodeRepositoryImpl implements TeacherCodeRepository {
  /// Creates the repository over [storage].
  const TeacherCodeRepositoryImpl({required this._storage});

  /// Preference key of the code.
  static const String codeKey = 'teacher_code';

  static const String _logName = 'classroom';

  final LocalStorage _storage;

  @override
  Future<DataState<String?>> readCode() {
    return _guard(() => _storage.readString(key: codeKey));
  }

  @override
  Future<DataState<void>> saveCode({required String code}) {
    return _guard(() => _storage.writeString(key: codeKey, value: code));
  }

  Future<DataState<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return DataSuccess<T>(await action());
    } on Exception catch (error, stackTrace) {
      log(
        'Preferences failure',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<T>(CacheException(message: error.toString()));
    }
  }
}
