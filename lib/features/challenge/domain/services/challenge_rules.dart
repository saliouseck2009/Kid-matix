import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_time_schedule.dart';

/// Rules of the free training and of the challenges.
abstract final class ChallengeRules {
  /// Question counts the free training offers.
  static const List<int> trainingQuestionCounts = <int>[10, 20, 30];

  /// Time per question of the free training with the normal timer.
  static const Duration trainingTimeLimit = Duration(seconds: 10);

  /// The four question types of version 1.0: the mastery engine picks
  /// among them by box.
  static const List<String> versionOneQuestionTypeIds = <String>[
    QuestionTypeIds.multipleChoice,
    QuestionTypeIds.trueFalse,
    QuestionTypeIds.typedAnswer,
    QuestionTypeIds.missingNumber,
  ];

  /// Question types of the free training: every format, the mastery
  /// engine picks among them by box (lot F15).
  static const List<String> trainingQuestionTypeIds = <String>[
    ...versionOneQuestionTypeIds,
    QuestionTypeIds.findOperation,
    QuestionTypeIds.matchPairs,
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

  /// Lives of a survival game: it ends at the third mistake.
  static const int survivalLives = 3;

  /// Time per question of a survival game with the normal timer: 10
  /// seconds, half a second less every 5 right answers, never below 4
  /// seconds (owner's choice); the relaxed timer stretches it all.
  static const QuizTimeSchedule survivalTimeSchedule = QuizTimeSchedule(
    start: Duration(seconds: 10),
    step: Duration(milliseconds: 500),
    stepEvery: 5,
    floor: Duration(seconds: 4),
  );

  /// Questions prepared for a survival game: more than anyone answers
  /// before losing 3 lives.
  static const int survivalQuestionCount = 300;

  /// Question types of a survival game: answers to pick only, like the
  /// time attack (owner's choice).
  static const List<String> survivalQuestionTypeIds = <String>[
    QuestionTypeIds.multipleChoice,
  ];

  /// Questions of the daily review.
  static const int dailyReviewQuestionCount = 10;

  /// The formats of the numbers (lot F24): the daily review mixes every
  /// domain, and some items of the numbers have no other format.
  static const List<String> numberQuestionTypeIds = <String>[
    QuestionTypeIds.countObjects,
    QuestionTypeIds.tensAndOnes,
    QuestionTypeIds.numberLine,
    QuestionTypeIds.compare,
  ];

  /// The formats of the math words (lot F28) that test a word: the daily
  /// review mixes every domain, and every word has at least the first two.
  /// Touching the words of a sentence is discovery only and is not asked.
  static const List<String> wordQuestionTypeIds = <String>[
    QuestionTypeIds.listenAndTouch,
    QuestionTypeIds.wordAndImage,
    QuestionTypeIds.whichOperation,
  ];

  /// Question types of the daily review: the mastery engine picks among
  /// them by box, among those that fit each item.
  static const List<String> dailyReviewQuestionTypeIds = <String>[
    ...versionOneQuestionTypeIds,
    ...numberQuestionTypeIds,
    ...wordQuestionTypeIds,
  ];

  /// Questions of a monster hunt: each monster twice, completed like a
  /// daily review (owner's choice).
  static const int monsterHuntQuestionCount = 10;

  /// Question types of a monster hunt: the mastery engine picks among
  /// them by box, as in the daily review.
  static const List<String> monsterHuntQuestionTypeIds =
      versionOneQuestionTypeIds;
}
