import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/challenge/data/datasources/challenge_tables.dart';
import 'package:kid_matix/features/challenge/data/datasources/record_local_data_source.dart';
import 'package:kid_matix/features/challenge/data/models/record_local_model.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/domain/services/record_policy.dart';
import 'package:sqflite/sqflite.dart';

/// Writes a new record in the transaction that saves a completed quiz of
/// a mode with records, when its right answers beat the player's best.
final class RecordSessionHook implements SessionSavedHook {
  /// Creates the hook.
  const RecordSessionHook({
    required this._records,
    required this._clock,
    this._policy = const RecordPolicy(),
  });

  final RecordLocalDataSource _records;
  final Clock _clock;
  final RecordPolicy _policy;

  @override
  Future<SessionWrite> prepare({required SavedQuizSession session}) async {
    if (!session.isCompleted ||
        !RecordPolicy.recordModes.contains(session.mode)) {
      return (Transaction transaction) async => const <String>[];
    }
    return (Transaction transaction) => _write(transaction, session);
  }

  Future<List<String>> _write(
    Transaction transaction,
    SavedQuizSession session,
  ) async {
    final RecordLocalModel? current = await _records.getRecord(
      transaction,
      profileId: session.profileId,
      mode: session.mode,
    );
    final RecordEntity? record = _policy.newRecordOf(
      mode: session.mode,
      score: session.correctCount,
      sessionId: session.id,
      endedAt: session.endedAt,
      current: current?.toEntity(),
    );
    if (record == null) return const <String>[];
    await _records.upsertRecord(
      transaction,
      record: RecordLocalModel.fromEntity(
        profileId: session.profileId,
        record: record,
        updatedAt: _clock.now(),
      ),
    );
    return const <String>[ChallengeTables.record];
  }
}
