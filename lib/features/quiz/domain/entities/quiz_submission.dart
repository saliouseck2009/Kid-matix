import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:meta/meta.dart';

/// Outcome of an answer: the judged turn and the run that follows.
@immutable
final class QuizSubmission {
  /// Creates the outcome.
  const QuizSubmission({
    required this.turn,
    required this.answer,
    required this.run,
  });

  /// Turn that was answered.
  final QuizTurn turn;

  /// Record of the answer, right or wrong.
  final QuizAnswerEntity answer;

  /// Run after the answer: the turn is gone, a second chance may be queued.
  final QuizRun run;
}
