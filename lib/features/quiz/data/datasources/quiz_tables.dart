/// Names of the tables of the quiz sessions.
abstract final class QuizTables {
  /// Sessions, one row per completed or abandoned quiz.
  static const String session = 'quiz_session';

  /// Answers, one row per answer of a session.
  static const String answer = 'quiz_answer';
}
