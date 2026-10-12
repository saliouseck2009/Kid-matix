import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_mode.dart';

/// Rules of the games replayed from a challenge code.
abstract final class CodeChallengeRules {
  /// Domain of the tables a code names.
  static const String domainId = LearningDomainIds.multiplication;

  /// Question counts a free training can be coded with.
  static const List<int> trainingQuestionCounts = <int>[10, 20, 30];

  /// Question types of a coded free training with generator version 1:
  /// the six formats of lot F15, drawn evenly since the mastery plays no
  /// part. Frozen: changing the list or its order changes the questions
  /// of every code already shared, so it needs a new version.
  static const List<String> versionOneTrainingQuestionTypeIds = <String>[
    QuestionTypeIds.multipleChoice,
    QuestionTypeIds.trueFalse,
    QuestionTypeIds.typedAnswer,
    QuestionTypeIds.missingNumber,
    QuestionTypeIds.findOperation,
    QuestionTypeIds.matchPairs,
  ];

  /// Question types of a coded time attack with generator version 1:
  /// multiple choice, as in every time attack. Frozen like
  /// [versionOneTrainingQuestionTypeIds].
  static const List<String> versionOneTimeAttackQuestionTypeIds = <String>[
    QuestionTypeIds.multipleChoice,
  ];

  /// Question types of a coded game of [mode]; generator version 1 is
  /// the only one so far.
  static List<String> questionTypeIdsOf(ChallengeCodeMode mode) {
    return mode.isTraining
        ? versionOneTrainingQuestionTypeIds
        : versionOneTimeAttackQuestionTypeIds;
  }
}
