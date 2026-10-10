import 'dart:async';
import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/learning_path/data/datasources/learning_path_tables.dart';
import 'package:kid_matix/features/learning_path/data/datasources/stage_progress_local_data_source.dart';
import 'package:kid_matix/features/learning_path/data/models/stage_progress_local_model.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/stage_progress_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [StageProgressRepository] over the local database.
///
/// The rows are written by `StageProgressSessionHook` when a quiz session
/// is saved; this repository only reads them.
final class StageProgressRepositoryImpl implements StageProgressRepository {
  /// Creates the repository.
  const StageProgressRepositoryImpl({
    required this._progress,
    required this._changeBus,
  });

  static const String _logName = 'learning_path';

  final StageProgressLocalDataSource _progress;
  final TableChangeBus _changeBus;

  @override
  Stream<void> watchChanges() {
    final List<StreamSubscription<String>> subscriptions =
        <StreamSubscription<String>>[];
    late final StreamController<void> controller;
    controller = StreamController<void>(
      onListen: () {
        for (final String table in <String>[
          LearningPathTables.stageProgress,
          LearningPathTables.profile,
        ]) {
          subscriptions.add(
            _changeBus.watchTable(table: table).listen((_) {
              controller.add(null);
            }),
          );
        }
      },
      onCancel: () async {
        for (final StreamSubscription<String> subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream;
  }

  @override
  Future<DataState<List<StageProgressEntity>>> getProgress({
    required String profileId,
    required String domainId,
  }) async {
    try {
      final List<StageProgressLocalModel> rows = await _progress.getProgress(
        profileId: profileId,
        domainId: domainId,
      );
      return DataSuccess<List<StageProgressEntity>>(
        rows.map((StageProgressLocalModel row) => row.toEntity()).toList(),
      );
    } on DatabaseException catch (error, stackTrace) {
      log(
        'Stage progress not read',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<List<StageProgressEntity>>(
        CacheException(message: error.toString()),
      );
    }
  }
}
