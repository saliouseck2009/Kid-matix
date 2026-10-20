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

  /// Preference key set while a forgotten code waits for a new one.
  static const String forgottenKey = 'teacher_code_forgotten';

  /// Preference key of the date the code last changed.
  static const String changedAtKey = 'teacher_code_changed_at';

  /// Preference key of the end of the lockout after wrong codes; kept, so
  /// closing the app does not open the door.
  static const String lockedUntilKey = 'teacher_code_locked_until';

  static const String _logName = 'classroom';

  final LocalStorage _storage;

  @override
  Future<DataState<String?>> readCode() {
    return _guard(() => _storage.readString(key: codeKey));
  }

  @override
  Future<DataState<void>> saveCode({
    required String code,
    required DateTime savedAt,
  }) {
    return _guard(() async {
      await _storage.writeString(key: codeKey, value: code);
      if (await _storage.readString(key: forgottenKey) == null) return;
      await _storage.writeString(
        key: changedAtKey,
        value: savedAt.toIso8601String(),
      );
      await _storage.remove(key: forgottenKey);
    });
  }

  @override
  Future<DataState<void>> clearCode() {
    return _guard(() async {
      await _storage.remove(key: codeKey);
      await _storage.writeString(key: forgottenKey, value: 'true');
    });
  }

  @override
  Future<DataState<DateTime?>> readCodeChangedAt() => _readDate(changedAtKey);

  @override
  Future<DataState<DateTime?>> readLockedUntil() => _readDate(lockedUntilKey);

  @override
  Future<DataState<void>> saveLockedUntil({required DateTime? until}) {
    return _guard(
      () => until == null
          ? _storage.remove(key: lockedUntilKey)
          : _storage.writeString(
              key: lockedUntilKey,
              value: until.toIso8601String(),
            ),
    );
  }

  Future<DataState<DateTime?>> _readDate(String key) {
    return _guard(() async {
      final String? stored = await _storage.readString(key: key);
      return stored == null ? null : DateTime.tryParse(stored);
    });
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
