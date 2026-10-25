import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:meta/meta.dart';

/// What the quiz of a stage is made of.
@immutable
final class StageDefinition {
  /// Creates the definition.
  const StageDefinition({
    required this.kind,
    required this.questionTypeIds,
    required this.selection,
    this.questionCount,
    this.baseTimeLimit,
  });

  /// Most stars of a stage.
  static const int maxStars = 3;

  /// Questions of the review stage.
  static const int reviewQuestionCount = 15;

  /// Time per question of the speed stage.
  static const Duration speedTimeLimit = Duration(seconds: 10);

  /// Time per question of the boss fight.
  static const Duration bossTimeLimit = Duration(seconds: 8);

  /// Most follow-up questions of the boss fight, after the facts of its
  /// table.
  static const int bossFollowUpCount = 10;

  /// The five stages of a table, in order.
  static const List<StageDefinition> tableStages = <StageDefinition>[
    StageDefinition(
      kind: StageKind.discovery,
      questionTypeIds: <String>[
        QuestionTypeIds.multipleChoice,
        ..._numberTypes,
        QuestionTypeIds.touchToUnderstand,
        QuestionTypeIds.listenAndTouch,
        QuestionTypeIds.solveProblem,
      ],
      selection: QuizSelection.inOrder,
    ),
    StageDefinition(
      kind: StageKind.training,
      questionTypeIds: <String>[
        QuestionTypeIds.multipleChoice,
        QuestionTypeIds.trueFalse,
        ..._numberTypes,
        ..._wordTypes,
        ..._problemTypes,
      ],
      selection: QuizSelection.shuffled,
    ),
    StageDefinition(
      kind: StageKind.writing,
      questionTypeIds: <String>[
        QuestionTypeIds.typedAnswer,
        QuestionTypeIds.missingNumber,
        QuestionTypeIds.compare,
        QuestionTypeIds.whichOperation,
        QuestionTypeIds.wordAndImage,
        QuestionTypeIds.listenAndTouch,
        ..._problemTypes,
      ],
      selection: QuizSelection.shuffled,
    ),
    StageDefinition(
      kind: StageKind.speed,
      questionTypeIds: _timedTypes,
      selection: QuizSelection.shuffled,
      baseTimeLimit: speedTimeLimit,
    ),
    StageDefinition(
      kind: StageKind.boss,
      questionTypeIds: _timedTypes,
      selection: QuizSelection.shuffled,
      baseTimeLimit: bossTimeLimit,
    ),
  ];

  /// The review stage after every group of 3 tables.
  static const StageDefinition review = StageDefinition(
    kind: StageKind.review,
    questionTypeIds: <String>[
      ..._versionOneTypes,
      ..._numberTypes,
      ..._wordTypes,
      ..._problemTypes,
    ],
    selection: QuizSelection.mastery,
    questionCount: reviewQuestionCount,
  );

  /// The four formats of version 1.0, kept by the review stage.
  static const List<String> _versionOneTypes = <String>[
    QuestionTypeIds.multipleChoice,
    QuestionTypeIds.typedAnswer,
    QuestionTypeIds.missingNumber,
    QuestionTypeIds.trueFalse,
  ];

  /// The formats of the numbers (lot F24) other than the keypad: three
  /// to pick a number, and the comparison, the only format of its unit,
  /// so every stage of that unit asks it.
  ///
  /// A stage lists every format it may ask, whatever the domain: each
  /// item is asked with the formats of the list that fit it (see
  /// `LearningDomain.questionTypeIdsOf`), so a multiplication fact still
  /// gets exactly the formats of versions 1.0 and 1.1.
  static const List<String> _numberTypes = <String>[
    QuestionTypeIds.countObjects,
    QuestionTypeIds.tensAndOnes,
    QuestionTypeIds.numberLine,
    QuestionTypeIds.compare,
  ];

  /// The formats of the math words that test a word (lot F28): hear a word
  /// and touch its drawing, tie words to drawings, pick the operation of a
  /// statement. Each word is asked with the ones that fit it (a statement
  /// uses only some words). Touching the words of a sentence is discovery
  /// only and belongs to the Discovery stage alone.
  static const List<String> _wordTypes = <String>[
    QuestionTypeIds.listenAndTouch,
    QuestionTypeIds.wordAndImage,
    QuestionTypeIds.whichOperation,
  ];

  /// The formats of the word problems (lot F30) other than the guided
  /// solving, which is the lesson of the Discovery stage: the bar model
  /// and the choice of the operation of a statement.
  static const List<String> _problemTypes = <String>[
    QuestionTypeIds.barModel,
    QuestionTypeIds.problemOperation,
  ];

  /// The formats of the math words that suit a timed stage: a sentence to
  /// explore or a long statement does not fit the speed stage nor the
  /// boss arena.
  static const List<String> _timedWordTypes = <String>[
    QuestionTypeIds.listenAndTouch,
    QuestionTypeIds.wordAndImage,
  ];

  /// Every format, for the speed stage and the boss fight (lots F15, F24
  /// and F28).
  static const List<String> _timedTypes = <String>[
    ..._versionOneTypes,
    QuestionTypeIds.findOperation,
    QuestionTypeIds.matchPairs,
    ..._numberTypes,
    ..._timedWordTypes,
    QuestionTypeIds.problemOperation,
  ];

  /// Which stage it is.
  final StageKind kind;

  /// Question formats of the stage.
  final List<String> questionTypeIds;

  /// How the questions are chosen among the facts.
  final QuizSelection selection;

  /// Questions to ask, or `null` for every fact of the table once.
  final int? questionCount;

  /// Time per question with the normal timer, or `null` without a timer.
  final Duration? baseTimeLimit;

  /// Position of the stage in its table, from 1; 0 for the review.
  int get number => kind == StageKind.review ? 0 : kind.index + 1;
}
