import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/mascot/data/datasources/mascot_local_data_source.dart';
import 'package:kid_matix/features/mascot/data/datasources/mascot_tables.dart';
import 'package:kid_matix/features/mascot/data/models/mascot_local_model.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_record.dart';
import 'package:kid_matix/features/mascot/domain/repositories/mascot_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [MascotRepository] over the local database.
final class MascotRepositoryImpl implements MascotRepository {
  /// Creates the repository.
  const MascotRepositoryImpl({
    required this._mascots,
    required this._clock,
    required this._changeBus,
  });

  static const String _logName = 'mascot';

  final MascotLocalDataSource _mascots;
  final Clock _clock;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<MascotRecord>> getMascot({required String profileId}) async {
    try {
      final MascotLocalModel? row = await _mascots.getMascot(
        profileId: profileId,
      );
      return DataSuccess<MascotRecord>(
        row?.toRecord() ?? const MascotRecord.initial(),
      );
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Mascot not read', error, stackTrace);
    }
  }

  @override
  Future<DataState<void>> saveMascot({
    required String profileId,
    required MascotRecord mascot,
  }) async {
    try {
      await _mascots.upsertMascot(
        mascot: MascotLocalModel.fromRecord(
          profileId: profileId,
          mascot: mascot,
          updatedAt: _clock.now(),
        ),
      );
      _changeBus.notifyChanged(table: MascotTables.mascot);
      return const DataSuccess<void>(null);
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Mascot not saved', error, stackTrace);
    }
  }

  @override
  Stream<void> watchChanges() {
    return _changeBus.watchTable(table: MascotTables.mascot);
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
