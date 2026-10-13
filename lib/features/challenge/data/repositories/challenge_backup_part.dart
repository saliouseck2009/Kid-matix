import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:kid_matix/core/storage/backup_section_reader.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/features/challenge/data/datasources/challenge_tables.dart';
import 'package:kid_matix/features/challenge/data/datasources/training_choice_local_data_source.dart';
import 'package:kid_matix/features/challenge/data/models/record_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// The challenges of a player in a backup file: their records, and the
/// last free training they chose, kept in the device preferences.
final class ChallengeBackupPart implements ProfileBackupPart {
  /// Creates the part; [_choicesOf] gives the training choices when a
  /// backup is first written or read, so the preferences are not opened
  /// at startup.
  const ChallengeBackupPart({required this._choicesOf});

  static const String _recordsKey = 'records';
  static const String _trainingChoiceKey = 'trainingChoice';

  final TrainingChoiceLocalDataSource Function() _choicesOf;

  @override
  String get section => 'challenge';

  @override
  Future<Map<String, Object?>> exportSection(
    DatabaseExecutor executor, {
    required String profileId,
  }) async {
    final List<Map<String, Object?>> records = await executor.query(
      ChallengeTables.record,
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
      orderBy: 'mode',
    );
    return <String, Object?>{
      _recordsKey: records,
      _trainingChoiceKey: await _choicesOf().readChoice(profileId: profileId),
    };
  }

  /// Writes the records in [transaction]. The training choice is a
  /// preference outside the database: it is written at once, and a
  /// transaction rolled back leaves it pointing to no player, unread.
  @override
  Future<List<String>> importSection(
    Transaction transaction, {
    required Map<String, Object?> content,
    required BackupIdMap ids,
  }) async {
    final List<RecordLocalModel> records = BackupSectionReader.readRows(
      content,
      key: _recordsKey,
      fromJson: RecordLocalModel.fromJson,
    );
    final String? trainingChoice = BackupSectionReader.readText(
      content,
      key: _trainingChoiceKey,
    );
    final Batch batch = transaction.batch();
    for (final RecordLocalModel record in records) {
      batch.insert(ChallengeTables.record, <String, Object?>{
        ...record.toJson(),
        'profile_id': ids.profileId,
        'session_id': ids.remap(record.sessionId),
      });
    }
    await batch.commit(noResult: true);
    if (trainingChoice != null) {
      await _choicesOf().writeChoice(
        profileId: ids.profileId,
        sourceKey: trainingChoice,
      );
    }
    return const <String>[ChallengeTables.record];
  }
}
