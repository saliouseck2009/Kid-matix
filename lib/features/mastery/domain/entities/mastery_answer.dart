import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:meta/meta.dart';

/// An answer as the mastery engine weighs it.
@immutable
final class MasteryAnswer {
  /// Creates the answer.
  const MasteryAnswer({
    required this.isCorrect,
    required this.answerNature,
    required this.answerTime,
    this.isRetry = false,
  });

  /// Whether the answer was right; a timeout is a wrong answer.
  final bool isCorrect;

  /// Whether the answer was picked among choices or written.
  final AnswerNature answerNature;

  /// Time taken to answer.
  final Duration answerTime;

  /// Whether it was the second chance of a fact missed in the same quiz.
  final bool isRetry;
}
