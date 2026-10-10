import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/mastery/data/datasources/item_progress_local_data_source.dart';
import 'package:kid_matix/features/mastery/data/datasources/mastery_tables.dart';
import 'package:kid_matix/features/mastery/data/models/item_progress_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [ItemProgressLocalDataSource] over the app database.
final class ItemProgressLocalDataSourceImpl
    implements ItemProgressLocalDataSource {
  /// Creates the data source over [database].
  const ItemProgressLocalDataSourceImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<List<ItemProgressLocalModel>> getProgress({
    required String profileId,
    required String domainId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      MasteryTables.itemProgress,
      where: 'profile_id = ? AND domain_id = ? AND deleted_at IS NULL',
      whereArgs: <Object>[profileId, domainId],
    );
    return rows.map(ItemProgressLocalModel.fromJson).toList();
  }

  @override
  Future<ItemProgressLocalModel?> getItemProgress({
    required String profileId,
    required String domainId,
    required String itemKey,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      MasteryTables.itemProgress,
      where:
          'profile_id = ? AND domain_id = ? AND item_key = ? '
          'AND deleted_at IS NULL',
      whereArgs: <Object>[profileId, domainId, itemKey],
    );
    return rows.isEmpty ? null : ItemProgressLocalModel.fromJson(rows.single);
  }

  @override
  Future<void> upsertProgress({
    required ItemProgressLocalModel progress,
  }) async {
    final Database database = await _database.database;
    await database.insert(
      MasteryTables.itemProgress,
      progress.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
