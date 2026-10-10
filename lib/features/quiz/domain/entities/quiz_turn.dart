import 'package:kid_matix/core/quiz/question.dart';
import 'package:meta/meta.dart';

/// A question waiting in the quiz, scored or a second chance.
@immutable
final class QuizTurn {
  /// Creates a turn for [question].
  const QuizTurn({required this.question, this.isRetry = false});

  /// Question to ask.
  final Question question;

  /// Whether it is the second chance of a missed fact.
  final bool isRetry;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizTurn &&
          other.question == question &&
          other.isRetry == isRetry;

  @override
  int get hashCode => Object.hash(question, isRetry);
}
