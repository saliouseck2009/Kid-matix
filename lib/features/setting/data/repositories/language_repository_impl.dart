import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/setting/data/datasources/language_local_data_source.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';
import 'package:kid_matix/features/setting/domain/repositories/language_repository.dart';

/// [LanguageRepository] over the device preferences.
final class LanguageRepositoryImpl implements LanguageRepository {
  /// Creates the repository.
  const LanguageRepositoryImpl({required this._local});

  static const String _logName = 'language';

  final LanguageLocalDataSource _local;

  @override
  Future<DataState<AppLanguage>> getLanguage() {
    return _guard(
      () async => await _local.readLanguage() ?? AppLanguage.system,
      failure: 'Language not read',
    );
  }

  @override
  Future<DataState<void>> saveLanguage({required AppLanguage language}) {
    return _guard(
      () => _local.writeLanguage(language: language),
      failure: 'Language not saved',
    );
  }

  Future<DataState<T>> _guard<T>(
    Future<T> Function() action, {
    required String failure,
  }) async {
    try {
      return DataSuccess<T>(await action());
    } on Object catch (error, stackTrace) {
      // The preferences plugin throws platform errors of no common type.
      log(failure, name: _logName, error: error, stackTrace: stackTrace);
      return DataFailed<T>(CacheException(message: error.toString()));
    }
  }
}
