import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/challenge/data/datasources/challenge_tables.dart';
import 'package:kid_matix/features/challenge/data/datasources/record_local_data_source.dart';
import 'package:kid_matix/features/challenge/data/models/record_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [RecordLocalDataSource] over the app database.
final class RecordLocalDataSourceImpl implements RecordLocalDataSource {
  /// Creates the data source over [database].
  const RecordLocalDataSourceImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<List<RecordLocalModel>> getRecords({required String profileId}) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ChallengeTables.record,
      where: 'profile_id = ? AND deleted_at IS NULL',
      whereArgs: <Object>[profileId],
    );
    return rows.map(RecordLocalModel.fromJson).toList();
  }

  @override
  Future<RecordLocalModel?> getRecordOfSession({
    required String sessionId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ChallengeTables.record,
      where: 'session_id = ? AND deleted_at IS NULL',
      whereArgs: <Object>[sessionId],
    );
    return rows.isEmpty ? null : RecordLocalModel.fromJson(rows.first);
  }

  @override
  Future<RecordLocalModel?> getRecord(
    DatabaseExecutor executor, {
    required String profileId,
    required QuizMode mode,
  }) async {
    final List<Map<String, Object?>> rows = await executor.query(
      ChallengeTables.record,
      where: 'profile_id = ? AND mode = ? AND deleted_at IS NULL',
      whereArgs: <Object>[profileId, mode.name],
    );
    return rows.isEmpty ? null : RecordLocalModel.fromJson(rows.single);
  }

  @override
  Future<void> upsertRecord(
    DatabaseExecutor executor, {
    required RecordLocalModel record,
  }) async {
    await executor.insert(
      ChallengeTables.record,
      record.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
