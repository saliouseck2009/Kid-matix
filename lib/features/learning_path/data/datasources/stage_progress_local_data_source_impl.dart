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

  final AppDatabase _database;

  @override
  Future<List<StageProgressLocalModel>> getProgress({
    required String profileId,
    required String domainId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      LearningPathTables.stageProgress,
      where: 'profile_id = ? AND domain_id = ? AND deleted_at IS NULL',
      whereArgs: <Object>[profileId, domainId],
    );
    return rows.map(StageProgressLocalModel.fromJson).toList();
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
