import 'dart:math';

import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/learning_path/data/datasources/learning_path_tables.dart';
import 'package:kid_matix/features/learning_path/data/datasources/stage_progress_local_data_source.dart';
import 'package:kid_matix/features/learning_path/data/models/stage_progress_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [StageProgressLocalDataSource] over the app database.
final class StageProgressLocalDataSourceImpl
    implements StageProgressLocalDataSource {
  /// Creates the data source over [database].
  const StageProgressLocalDataSourceImpl({required this._database});

  static const String _stageWhere =
      'profile_id = ? AND domain_id = ? AND unit_key = ? AND stage = ? '
      'AND deleted_at IS NULL';

  static const String _playerWhere =
      'profile_id = ? AND domain_id = ? AND deleted_at IS NULL';

  final AppDatabase _database;

  @override
  Future<List<StageProgressLocalModel>> getProgress({
    required String profileId,
    required String domainId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      LearningPathTables.stageProgress,
      where: '$_playerWhere AND stage != ?',
      whereArgs: <Object>[
        profileId,
        domainId,
        LearningPathTables.placementStage,
      ],
    );
    return rows.map(StageProgressLocalModel.fromJson).toList();
  }

  @override
  Future<Set<String>> getPlacedUnitKeys({
    required String profileId,
    required String domainId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      LearningPathTables.stageProgress,
      columns: const <String>['unit_key'],
      where: '$_playerWhere AND stage = ?',
      whereArgs: <Object>[
        profileId,
        domainId,
        LearningPathTables.placementStage,
      ],
    );
    return <String>{
      for (final Map<String, Object?> row in rows) row['unit_key']! as String,
    };
  }

  @override
  Future<void> placeUnit({
    required String profileId,
    required String domainId,
    required String unitKey,
    required int placedAt,
  }) async {
    final Database database = await _database.database;
    await database.insert(
      LearningPathTables.stageProgress,
      <String, Object?>{
        'profile_id': profileId,
        'domain_id': domainId,
        'unit_key': unitKey,
        'stage': LearningPathTables.placementStage,
        'best_stars': 0,
        'best_score': 1,
        'completed_at': placedAt,
        'updated_at': placedAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> keepBest({
    required DatabaseExecutor executor,
    required StageProgressLocalModel result,
  }) async {
    final List<Map<String, Object?>> rows = await executor.query(
      LearningPathTables.stageProgress,
      where: _stageWhere,
      whereArgs: <Object>[
        result.profileId,
        result.domainId,
        result.unitKey,
        result.stage.name,
      ],
    );
    final StageProgressLocalModel? stored = rows.isEmpty
        ? null
        : StageProgressLocalModel.fromJson(rows.single);
    await executor.insert(
      LearningPathTables.stageProgress,
      StageProgressLocalModel(
        profileId: result.profileId,
        domainId: result.domainId,
        unitKey: result.unitKey,
        stage: result.stage,
        bestStars: max(result.bestStars, stored?.bestStars ?? 0),
        bestScore: max(result.bestScore, stored?.bestScore ?? 0),
        completedAt: stored?.completedAt ?? result.completedAt,
        updatedAt: result.updatedAt,
      ).toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
