import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/challenge/data/datasources/challenge_tables.dart';
import 'package:kid_matix/features/challenge/data/datasources/record_local_data_source.dart';
import 'package:kid_matix/features/challenge/data/models/record_local_model.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/domain/repositories/record_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [RecordRepository] over the local database; the records are written
/// by the session hook of the challenges.
final class RecordRepositoryImpl implements RecordRepository {
  /// Creates the repository.
  const RecordRepositoryImpl({
    required this._records,
    required this._changeBus,
  });

  static const String _logName = 'challenge';

  final RecordLocalDataSource _records;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<List<RecordEntity>>> getRecords({
    required String profileId,
  }) async {
    try {
      final List<RecordLocalModel> rows = await _records.getRecords(
        profileId: profileId,
      );
      return DataSuccess<List<RecordEntity>>(
        rows.map((RecordLocalModel row) => row.toEntity()).toList(),
      );
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Records not read', error, stackTrace);
    }
  }

  @override
  Future<DataState<RecordEntity?>> getRecordOfSession({
    required String sessionId,
  }) async {
    try {
      final RecordLocalModel? row = await _records.getRecordOfSession(
        sessionId: sessionId,
      );
      return DataSuccess<RecordEntity?>(row?.toEntity());
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Record not read', error, stackTrace);
    }
  }

  @override
  Stream<void> watchChanges() {
    return _changeBus.watchTable(table: ChallengeTables.record);
  }

  DataFailed<T> _fail<T>(
    String message,
    DatabaseException error,
    StackTrace stackTrace,
  ) {
    log(message, name: _logName, error: error, stackTrace: stackTrace);
    return DataFailed<T>(CacheException(message: error.toString()));
  }
}
