import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
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
    this.selection = QuizSelection.mastery,
    this.questionCount,
    this.baseTimeLimit,
    this.sourceKey,
    this.followUpItemKeys = const <String>[],
    this.followUpQuestionCount = 0,
    this.isBossFight = false,
  });

  /// Creates the request of [profileId] to play [spec].
  factory QuizRequest.fromSpec({
    required String profileId,
    required QuizSpec spec,
  }) {
    return QuizRequest(
      profileId: profileId,
      domainId: spec.domainId,
      mode: spec.mode,
      itemKeys: spec.itemKeys,
      questionTypeIds: spec.questionTypeIds,
      selection: spec.selection,
      questionCount: spec.questionCount,
      baseTimeLimit: spec.baseTimeLimit,
      sourceKey: spec.sourceKey,
      followUpItemKeys: spec.followUpItemKeys,
      followUpQuestionCount: spec.followUpQuestionCount,
      isBossFight: spec.isBossFight,
    );
  }

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

  /// Time per question with the normal timer, or `null` for a quiz that
  /// never has a timer; the player's timer mode then applies.
  final Duration? baseTimeLimit;

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
}
