import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:kid_matix/core/storage/backup_section_reader.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_tables.dart';
import 'package:kid_matix/features/quiz/data/models/quiz_answer_local_model.dart';
import 'package:kid_matix/features/quiz/data/models/quiz_session_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// The quiz journal of a player in a backup file: their sessions and the
/// answers of each.
final class QuizBackupPart implements ProfileBackupPart {
  /// Creates the part.
  const QuizBackupPart();

  static const String _sessionsKey = 'sessions';
  static const String _answersKey = 'answers';

  @override
  String get section => 'quiz';

  @override
  Future<Map<String, Object?>> exportSection(
    DatabaseExecutor executor, {
    required String profileId,
  }) async {
    final List<Map<String, Object?>> sessions = await executor.query(
      QuizTables.session,
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
      orderBy: 'started_at, id',
    );
    final List<Map<String, Object?>> answers = await executor.rawQuery(
      'SELECT a.* FROM ${QuizTables.answer} a '
      'JOIN ${QuizTables.session} s ON s.id = a.session_id '
      'WHERE s.profile_id = ? ORDER BY a.session_id, a.position',
      <Object>[profileId],
    );
    return <String, Object?>{_sessionsKey: sessions, _answersKey: answers};
  }

  @override
  Future<List<String>> importSection(
    Transaction transaction, {
    required Map<String, Object?> content,
    required BackupIdMap ids,
  }) async {
    final List<QuizSessionLocalModel> sessions = BackupSectionReader.readRows(
      content,
      key: _sessionsKey,
      fromJson: QuizSessionLocalModel.fromJson,
    );
    final List<QuizAnswerLocalModel> answers = BackupSectionReader.readRows(
      content,
      key: _answersKey,
      fromJson: QuizAnswerLocalModel.fromJson,
    );
    _checkAnswersHaveSessions(sessions, answers);
    final Batch batch = transaction.batch();
    for (final QuizSessionLocalModel session in sessions) {
      batch.insert(QuizTables.session, <String, Object?>{
        ...session.toJson(),
        'id': ids.remap(session.id),
        'profile_id': ids.profileId,
      });
    }
    for (final QuizAnswerLocalModel answer in answers) {
      batch.insert(QuizTables.answer, <String, Object?>{
        ...answer.toJson(),
        'session_id': ids.remap(answer.sessionId),
      });
    }
    await batch.commit(noResult: true);
    return const <String>[QuizTables.session, QuizTables.answer];
  }

  void _checkAnswersHaveSessions(
    List<QuizSessionLocalModel> sessions,
    List<QuizAnswerLocalModel> answers,
  ) {
    final Set<String> sessionIds = sessions
        .map((QuizSessionLocalModel session) => session.id)
        .toSet();
    for (final QuizAnswerLocalModel answer in answers) {
      if (!sessionIds.contains(answer.sessionId)) {
        throw FormatException('Answer of unknown session ${answer.sessionId}.');
      }
    }
  }
}
