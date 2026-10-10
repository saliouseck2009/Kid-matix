import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/challenge/data/models/record_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// Access to the `record` table.
abstract interface class RecordLocalDataSource {
  /// Returns the records of [profileId].
  Future<List<RecordLocalModel>> getRecords({required String profileId});

  /// Returns the record set by [sessionId], or `null`.
  Future<RecordLocalModel?> getRecordOfSession({required String sessionId});

  /// Returns the record of [profileId] in [mode], read in [executor], or
  /// `null`.
  Future<RecordLocalModel?> getRecord(
    DatabaseExecutor executor, {
    required String profileId,
    required QuizMode mode,
  });

  /// Writes [record] in [executor], replacing the previous one.
  Future<void> upsertRecord(
    DatabaseExecutor executor, {
    required RecordLocalModel record,
  });
}
