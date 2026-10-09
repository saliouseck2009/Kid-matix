import 'package:meta/meta.dart';

/// One answer given during a quiz session.
@immutable
final class QuizAnswerEntity {
  /// Creates an answer record.
  const QuizAnswerEntity({
    required this.itemKey,
    required this.questionTypeId,
    required this.isCorrect,
    required this.isTimedOut,
    required this.isRetry,
    required this.answerTime,
  });

  /// Longest answer time of a right answer that earns the "Éclair" mention.
  static const Duration lightningLimit = Duration(seconds: 3);

  /// Key of the item asked, such as `mul:7x8`.
  final String itemKey;

  /// Type of the question asked.
  final String questionTypeId;

  /// Whether the answer was right.
  final bool isCorrect;

  /// Whether the timer ran out before an answer; then [isCorrect] is false.
  final bool isTimedOut;

  /// Whether the question was the second chance of a missed fact, which
  /// does not count in the session score.
  final bool isRetry;

  /// Time between the question appearing and the answer, pauses excluded.
  final Duration answerTime;

  /// Whether the right answer came fast enough for the "Éclair" mention.
  bool get isLightning => isCorrect && answerTime < lightningLimit;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuizAnswerEntity &&
            other.itemKey == itemKey &&
            other.questionTypeId == questionTypeId &&
            other.isCorrect == isCorrect &&
            other.isTimedOut == isTimedOut &&
            other.isRetry == isRetry &&
            other.answerTime == answerTime;
  }

  @override
  int get hashCode => Object.hash(
    itemKey,
    questionTypeId,
    isCorrect,
    isTimedOut,
    isRetry,
    answerTime,
  );
}
