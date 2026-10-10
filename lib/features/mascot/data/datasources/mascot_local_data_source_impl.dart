import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/mascot/data/datasources/mascot_local_data_source.dart';
import 'package:kid_matix/features/mascot/data/datasources/mascot_tables.dart';
import 'package:kid_matix/features/mascot/data/models/mascot_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [MascotLocalDataSource] over the app database.
final class MascotLocalDataSourceImpl implements MascotLocalDataSource {
  /// Creates the data source over [database].
  const MascotLocalDataSourceImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<MascotLocalModel?> getMascot({required String profileId}) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      MascotTables.mascot,
      where: 'profile_id = ? AND deleted_at IS NULL',
      whereArgs: <Object>[profileId],
    );
    return rows.isEmpty ? null : MascotLocalModel.fromJson(rows.single);
  }

  @override
  Future<void> upsertMascot({required MascotLocalModel mascot}) async {
    final Database database = await _database.database;
    await database.insert(
      MascotTables.mascot,
      mascot.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
