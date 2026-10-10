import 'package:kid_matix/features/quiz/domain/entities/quiz_mode.dart';
import 'package:meta/meta.dart';

/// A quiz to play, as the screen that starts it describes it.
@immutable
final class QuizRequest {
  /// Creates the request.
  const QuizRequest({
    required this.profileId,
    required this.domainId,
    required this.mode,
    required this.itemKeys,
    required this.questionTypeIds,
    this.questionCount,
    this.baseTimeLimit,
  });

  /// Player of the quiz.
  final String profileId;

  /// Learning domain, such as `multiplication`.
  final String domainId;

  /// How the quiz is started.
  final QuizMode mode;

  /// Items to draw the questions from.
  final List<String> itemKeys;

  /// Scored questions to ask, or `null` for as many as [itemKeys].
  final int? questionCount;

  /// Question types to draw from.
  final List<String> questionTypeIds;

  /// Time per question with the normal timer, or `null` for a quiz that
  /// never has a timer; the player's timer mode then applies.
  final Duration? baseTimeLimit;
}
