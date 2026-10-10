import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/progress_reset_service.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:sqflite/sqflite.dart';

/// [ProgressResetService] running every [ProgressResetHook] in one
/// transaction, then telling the [TableChangeBus] which tables changed.
final class ProgressResetter implements ProgressResetService {
  /// Creates the resetter.
  const ProgressResetter({
    required this._database,
    required this._hooks,
    required this._changeBus,
  });

  static const String _logName = 'storage';

  final AppDatabase _database;
  final ProgressResetHooks _hooks;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<void>> resetProgress({required String profileId}) async {
    try {
      final Database database = await _database.database;
      final List<String> tables = await database.transaction((
        Transaction transaction,
      ) async {
        final List<String> written = <String>[];
        for (final ProgressResetHook hook in _hooks.hooks) {
          written.addAll(
            await hook.reset(transaction, profileId: profileId),
          );
        }
        return written;
      });
      for (final String table in tables.toSet()) {
        _changeBus.notifyChanged(table: table);
      }
      return const DataSuccess<void>(null);
    } on DatabaseException catch (error, stackTrace) {
      log(
        'Progress not reset',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<void>(CacheException(message: error.toString()));
    }
  }
}
