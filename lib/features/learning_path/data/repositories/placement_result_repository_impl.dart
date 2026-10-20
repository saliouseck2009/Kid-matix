import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/learning_path/data/datasources/learning_path_tables.dart';
import 'package:kid_matix/features/learning_path/data/datasources/placement_result_local_data_source.dart';
import 'package:kid_matix/features/learning_path/data/models/placement_result_local_model.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_outcome.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/placement_result_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [PlacementResultRepository] over the local database.
final class PlacementResultRepositoryImpl implements PlacementResultRepository {
  /// Creates the repository.
  const PlacementResultRepositoryImpl({
    required this._results,
    required this._changeBus,
    required this._clock,
  });

  static const String _logName = 'learning_path';

  final PlacementResultLocalDataSource _results;
  final TableChangeBus _changeBus;
  final Clock _clock;

  @override
  Stream<void> watchChanges() {
    return _changeBus.watchTable(table: LearningPathTables.placementResult);
  }

  @override
  Future<DataState<void>> save({
    required String profileId,
    required PlacementOutcome outcome,
  }) async {
    final int now = _clock.now().millisecondsSinceEpoch;
    try {
      await _results.insertAll(<PlacementResultLocalModel>[
        for (final DomainLevel level in outcome.domains)
          PlacementResultLocalModel(
            profileId: profileId,
            takenAt: now,
            domainId: level.domainId,
            level: level.level,
            skillCount: level.skillCount,
            unitCount: level.openedUnitKeys.length,
            startUnitKey: level.domainId == outcome.recommendedDomainId
                ? outcome.recommendedUnitKey
                : null,
            updatedAt: now,
          ),
      ]);
      _changeBus.notifyChanged(table: LearningPathTables.placementResult);
      return const DataSuccess<void>(null);
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Placement result not saved', error, stackTrace);
    }
  }

  @override
  Future<DataState<List<PlacementResultEntity>>> getHistory({
    required String profileId,
  }) async {
    try {
      final List<PlacementResultLocalModel> rows = await _results.getRows(
        profileId: profileId,
      );
      final Map<int, List<PlacementResultLocalModel>> byTest =
          <int, List<PlacementResultLocalModel>>{};
      for (final PlacementResultLocalModel row in rows) {
        byTest
            .putIfAbsent(row.takenAt, () => <PlacementResultLocalModel>[])
            .add(row);
      }
      return DataSuccess<List<PlacementResultEntity>>(<PlacementResultEntity>[
        for (final MapEntry<int, List<PlacementResultLocalModel>> test
            in byTest.entries)
          PlacementResultEntity(
            takenAt: DateTime.fromMillisecondsSinceEpoch(test.key),
            domains: test.value
                .map((PlacementResultLocalModel row) => row.toEntity())
                .toList(),
          ),
      ]);
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Placement results not read', error, stackTrace);
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
