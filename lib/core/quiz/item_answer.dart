import 'package:meta/meta.dart';

/// An answer given by a player to a question about one item, as the quiz
/// reports it to the mastery engine.
@immutable
final class ItemAnswer {
  /// Creates the answer.
  const ItemAnswer({
    required this.profileId,
    required this.domainId,
    required this.itemKey,
    required this.questionTypeId,
    required this.isCorrect,
    required this.answerTime,
    this.isRetry = false,
  });

  /// Player who answered.
  final String profileId;

  /// Learning domain of the item.
  final String domainId;

  /// Key of the item asked, such as `mul:7x8`.
  final String itemKey;

  /// Type of the question asked.
  final String questionTypeId;

  /// Whether the answer was right; a timeout is a wrong answer.
  final bool isCorrect;

  /// Time taken to answer.
  final Duration answerTime;

  /// Whether it was the second chance of a fact missed in the same quiz.
  final bool isRetry;
}
