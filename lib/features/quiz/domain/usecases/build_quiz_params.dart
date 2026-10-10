import 'package:kid_matix/features/quiz/domain/entities/quiz_mode.dart';
import 'package:meta/meta.dart';

/// What a quiz is made of.
@immutable
final class BuildQuizParams {
  /// Creates the parameters of a quiz.
  const BuildQuizParams({
    required this.profileId,
    required this.domainId,
    required this.mode,
    required this.itemKeys,
    required this.questionTypeIds,
    this.timeLimit,
  });

  /// Player of the quiz.
  final String profileId;

  /// Learning domain, such as `multiplication`.
  final String domainId;

  /// How the quiz is started.
  final QuizMode mode;

  /// Items to ask, one scored question each, in this order.
  final List<String> itemKeys;

  /// Question types to draw from.
  final List<String> questionTypeIds;

  /// Time to answer each question, or `null` without a timer.
  final Duration? timeLimit;
}
