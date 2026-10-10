import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
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
    this.selection = QuizSelection.mastery,
    this.questionCount,
    this.timeLimit,
    this.sourceKey,
  });

  /// Player of the quiz.
  final String profileId;

  /// Learning domain, such as `multiplication`.
  final String domainId;

  /// How the quiz is started.
  final QuizMode mode;

  /// Items to draw the questions from.
  final List<String> itemKeys;

  /// How the questions are chosen among [itemKeys].
  final QuizSelection selection;

  /// Scored questions to ask, or `null` for as many as [itemKeys].
  final int? questionCount;

  /// Question types to draw from.
  final List<String> questionTypeIds;

  /// Time to answer each question, or `null` without a timer.
  final Duration? timeLimit;

  /// What the quiz is played for, such as a stage of the learning path,
  /// or `null`.
  final String? sourceKey;
}
