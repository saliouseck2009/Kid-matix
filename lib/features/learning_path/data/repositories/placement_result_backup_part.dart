import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:kid_matix/core/storage/backup_section_reader.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/features/learning_path/data/datasources/learning_path_tables.dart';
import 'package:kid_matix/features/learning_path/data/models/placement_result_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// The dated placement results of a player in a backup file.
final class PlacementResultBackupPart implements ProfileBackupPart {
  /// Creates the part.
  const PlacementResultBackupPart();

  static const String _resultsKey = 'results';

  @override
  String get section => 'placementResults';

  @override
  Future<Map<String, Object?>> exportSection(
    DatabaseExecutor executor, {
    required String profileId,
  }) async {
    return <String, Object?>{
      _resultsKey: await executor.query(
        LearningPathTables.placementResult,
        where: 'profile_id = ? AND deleted_at IS NULL',
        whereArgs: <Object>[profileId],
        orderBy: 'taken_at, rowid',
      ),
    };
  }

  @override
  Future<List<String>> importSection(
    Transaction transaction, {
    required Map<String, Object?> content,
    required BackupIdMap ids,
  }) async {
    final List<PlacementResultLocalModel> results =
        BackupSectionReader.readRows(
          content,
          key: _resultsKey,
          fromJson: PlacementResultLocalModel.fromJson,
        );
    final Batch batch = transaction.batch();
    for (final PlacementResultLocalModel result in results) {
      batch.insert(LearningPathTables.placementResult, <String, Object?>{
        ...result.toJson(),
        'profile_id': ids.profileId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
    return const <String>[LearningPathTables.placementResult];
  }
}
