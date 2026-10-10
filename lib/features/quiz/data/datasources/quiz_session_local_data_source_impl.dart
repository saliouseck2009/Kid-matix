import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_session_local_data_source.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_tables.dart';
import 'package:kid_matix/features/quiz/data/models/quiz_answer_local_model.dart';
import 'package:kid_matix/features/quiz/data/models/quiz_session_local_model.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:sqflite/sqflite.dart';

/// [QuizSessionLocalDataSource] over the app database.
final class QuizSessionLocalDataSourceImpl
    implements QuizSessionLocalDataSource {
  /// Creates the data source over [database]; [hooks] write what the
  /// other features keep from a session in the same transaction.
  const QuizSessionLocalDataSourceImpl({
    required this._database,
    required this._hooks,
  });

  final AppDatabase _database;
  final SessionSavedHooks _hooks;

  @override
  Future<List<String>> insertSession({
    required QuizSessionLocalModel session,
    required List<QuizAnswerLocalModel> answers,
  }) async {
    final Database database = await _database.database;
    return database.transaction((Transaction transaction) async {
      await transaction.insert(QuizTables.session, session.toJson());
      final Batch batch = transaction.batch();
      for (final QuizAnswerLocalModel answer in answers) {
        batch.insert(QuizTables.answer, answer.toJson());
      }
      await batch.commit(noResult: true);
      final List<String> tables = <String>[];
      for (final SessionSavedHook hook in _hooks.hooks) {
        tables.addAll(
          await hook.onSessionSaved(
            transaction: transaction,
            session: _savedSessionOf(session),
          ),
        );
      }
      return tables;
    });
  }

  static SavedQuizSession _savedSessionOf(QuizSessionLocalModel session) {
    return SavedQuizSession(
      id: session.id,
      profileId: session.profileId,
      domainId: session.domainId,
      isCompleted: session.status == QuizSessionStatus.completed,
      questionCount: session.questionCount,
      correctCount: session.correctCount,
      endedAt: DateTime.fromMillisecondsSinceEpoch(
        session.startedAt + session.durationMs,
      ),
      sourceKey: session.sourceKey,
    );
  }

  @override
  Future<QuizSessionLocalModel?> getSession({required String sessionId}) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      QuizTables.session,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: <Object>[sessionId],
    );
    return rows.isEmpty ? null : QuizSessionLocalModel.fromJson(rows.single);
  }

  @override
  Future<List<QuizAnswerLocalModel>> getAnswers({
    required String sessionId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      QuizTables.answer,
      where: 'session_id = ? AND deleted_at IS NULL',
      whereArgs: <Object>[sessionId],
      orderBy: 'position',
    );
    return rows.map(QuizAnswerLocalModel.fromJson).toList();
  }
}
