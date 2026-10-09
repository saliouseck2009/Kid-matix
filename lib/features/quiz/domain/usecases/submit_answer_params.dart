import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:meta/meta.dart';

/// The answer to the current question of a run.
@immutable
final class SubmitAnswerParams {
  /// Creates the parameters; a `null` [answer] means the time ran out.
  const SubmitAnswerParams({
    required this.run,
    required this.answer,
    required this.answerTime,
  });

  /// Quiz being played.
  final QuizRun run;

  /// Answer given, or `null` when the timer ran out.
  final Answer? answer;

  /// Time taken to answer, pauses excluded.
  final Duration answerTime;
}
