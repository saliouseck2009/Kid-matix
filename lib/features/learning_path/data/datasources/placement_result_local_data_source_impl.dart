import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/learning_path/data/datasources/learning_path_tables.dart';
import 'package:kid_matix/features/learning_path/data/datasources/placement_result_local_data_source.dart';
import 'package:kid_matix/features/learning_path/data/models/placement_result_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [PlacementResultLocalDataSource] over the app database.
final class PlacementResultLocalDataSourceImpl
    implements PlacementResultLocalDataSource {
  /// Creates the data source over [database].
  const PlacementResultLocalDataSourceImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<void> insertAll(List<PlacementResultLocalModel> rows) async {
    final Database database = await _database.database;
    await database.transaction((Transaction transaction) async {
      for (final PlacementResultLocalModel row in rows) {
        await transaction.insert(
          LearningPathTables.placementResult,
          row.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<PlacementResultLocalModel>> getRows({
    required String profileId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      LearningPathTables.placementResult,
      where: 'profile_id = ? AND deleted_at IS NULL',
      whereArgs: <Object>[profileId],
      orderBy: 'taken_at DESC, rowid ASC',
    );
    return rows.map(PlacementResultLocalModel.fromJson).toList();
  }
}
