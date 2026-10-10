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
    this.followUpItemKeys = const <String>[],
    this.followUpQuestionCount = 0,
    this.isBossFight = false,
    this.totalTimeLimit,
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

  /// Items the mastery engine draws the follow-up questions from, after
  /// the main ones: the weakest first, each once.
  final List<String> followUpItemKeys;

  /// Most follow-up questions; 0 for none.
  final int followUpQuestionCount;

  /// Whether the quiz is a boss fight: every right answer hits the boss,
  /// and the fight ends when it falls or flees.
  final bool isBossFight;

  /// Time to play the whole quiz, or `null` when it ends with its last
  /// question.
  final Duration? totalTimeLimit;
}
