import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/mastery/data/datasources/item_progress_local_data_source.dart';
import 'package:kid_matix/features/mastery/data/datasources/mastery_tables.dart';
import 'package:kid_matix/features/mastery/data/models/item_progress_local_model.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [ItemProgressRepository] over the local database.
///
/// After each write it tells the [TableChangeBus] that the `item_progress`
/// table changed.
final class ItemProgressRepositoryImpl implements ItemProgressRepository {
  /// Creates the repository.
  const ItemProgressRepositoryImpl({
    required this._progress,
    required this._clock,
    required this._changeBus,
  });

  static const String _logName = 'mastery';

  final ItemProgressLocalDataSource _progress;
  final Clock _clock;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<List<ItemProgressEntity>>> getProgress({
    required String profileId,
    required String domainId,
  }) async {
    try {
      final List<ItemProgressLocalModel> rows = await _progress.getProgress(
        profileId: profileId,
        domainId: domainId,
      );
      return DataSuccess<List<ItemProgressEntity>>(
        rows.map((ItemProgressLocalModel row) => row.toEntity()).toList(),
      );
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Progress not read', error, stackTrace);
    }
  }

  @override
  Future<DataState<ItemProgressEntity>> getItemProgress({
    required String profileId,
    required String domainId,
    required String itemKey,
  }) async {
    try {
      final ItemProgressLocalModel? row = await _progress.getItemProgress(
        profileId: profileId,
        domainId: domainId,
        itemKey: itemKey,
      );
      return DataSuccess<ItemProgressEntity>(
        row?.toEntity() ??
            ItemProgressEntity.notSeen(
              profileId: profileId,
              domainId: domainId,
              itemKey: itemKey,
            ),
      );
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Item progress not read', error, stackTrace);
    }
  }

  @override
  Future<DataState<void>> saveProgress({
    required ItemProgressEntity progress,
  }) async {
    try {
      await _progress.upsertProgress(
        progress: ItemProgressLocalModel.fromEntity(
          progress: progress,
          updatedAt: _clock.now(),
        ),
      );
      _changeBus.notifyChanged(table: MasteryTables.itemProgress);
      return const DataSuccess<void>(null);
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Progress not saved', error, stackTrace);
    }
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
