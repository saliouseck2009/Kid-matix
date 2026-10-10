import 'package:kid_matix/features/quiz/data/models/quiz_answer_local_model.dart';
import 'package:kid_matix/features/quiz/data/models/quiz_session_local_model.dart';

/// Quiz sessions stored in the local SQLite database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository turns
/// them into typed failures.
abstract interface class QuizSessionLocalDataSource {
  /// Inserts [session] and its [answers] in one transaction, with what the
  /// session hooks of the other features write; returns the tables those
  /// hooks wrote.
  Future<List<String>> insertSession({
    required QuizSessionLocalModel session,
    required List<QuizAnswerLocalModel> answers,
  });

  /// Returns the session [sessionId], or `null` when there is none.
  Future<QuizSessionLocalModel?> getSession({required String sessionId});

  /// Returns the answers of [sessionId], in order.
  Future<List<QuizAnswerLocalModel>> getAnswers({required String sessionId});
}
