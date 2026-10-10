import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';

/// Rules of the free training and of the challenges.
abstract final class ChallengeRules {
  /// Question counts the free training offers.
  static const List<int> trainingQuestionCounts = <int>[10, 20, 30];

  /// Time per question of the free training with the normal timer.
  static const Duration trainingTimeLimit = Duration(seconds: 10);

  /// Question types of the free training: the mastery engine picks among
  /// them by box.
  static const List<String> trainingQuestionTypeIds = <String>[
    QuestionTypeIds.multipleChoice,
    QuestionTypeIds.trueFalse,
    QuestionTypeIds.typedAnswer,
    QuestionTypeIds.missingNumber,
  ];

  /// Time to play a time attack.
  static const Duration timeAttackTime = Duration(seconds: 60);

  /// Questions prepared for a time attack: more than anyone answers in
  /// [timeAttackTime].
  static const int timeAttackQuestionCount = 80;

  /// Question types of a time attack: answers to pick only, to measure
  /// the speed of recall (owner's choice).
  static const List<String> timeAttackQuestionTypeIds = <String>[
    QuestionTypeIds.multipleChoice,
  ];
}
