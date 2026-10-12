import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:kid_matix/core/storage/backup_section_reader.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/features/learning_path/data/datasources/learning_path_tables.dart';
import 'package:kid_matix/features/learning_path/data/models/placement_local_model.dart';
import 'package:kid_matix/features/learning_path/data/models/stage_progress_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// The learning path of a player in a backup file: the stars and crowns
/// of every stage, and apart, the tables opened by the placement test.
final class StageProgressBackupPart implements ProfileBackupPart {
  /// Creates the part.
  const StageProgressBackupPart();

  static const String _stagesKey = 'stages';
  static const String _placementsKey = 'placements';
  static const int _placementStars = 0;
  static const int _placementScore = 1;

  @override
  String get section => 'learningPath';

  @override
  Future<Map<String, Object?>> exportSection(
    DatabaseExecutor executor, {
    required String profileId,
  }) async {
    Future<List<Map<String, Object?>>> rowsOf(String stageTest) {
      return executor.query(
        LearningPathTables.stageProgress,
        where: 'profile_id = ? AND stage $stageTest ?',
        whereArgs: <Object>[profileId, LearningPathTables.placementStage],
        orderBy: 'domain_id, unit_key, stage',
      );
    }

    return <String, Object?>{
      _stagesKey: await rowsOf('!='),
      _placementsKey: await rowsOf('='),
    };
  }

  @override
  Future<List<String>> importSection(
    Transaction transaction, {
    required Map<String, Object?> content,
    required BackupIdMap ids,
  }) async {
    final List<StageProgressLocalModel> stages = BackupSectionReader.readRows(
      content,
      key: _stagesKey,
      fromJson: StageProgressLocalModel.fromJson,
    );
    final List<PlacementLocalModel> placements = BackupSectionReader.readRows(
      content,
      key: _placementsKey,
      fromJson: PlacementLocalModel.fromJson,
    );
    final Batch batch = transaction.batch();
    for (final StageProgressLocalModel stage in stages) {
      batch.insert(LearningPathTables.stageProgress, <String, Object?>{
        ...stage.toJson(),
        'profile_id': ids.profileId,
      });
    }
    for (final PlacementLocalModel placement in placements) {
      batch.insert(LearningPathTables.stageProgress, <String, Object?>{
        ...placement.toJson(),
        'profile_id': ids.profileId,
        'stage': LearningPathTables.placementStage,
        'best_stars': _placementStars,
        'best_score': _placementScore,
      });
    }
    await batch.commit(noResult: true);
    return const <String>[LearningPathTables.stageProgress];
  }
}
