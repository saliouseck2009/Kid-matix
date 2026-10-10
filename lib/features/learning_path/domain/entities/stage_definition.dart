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

  /// Questions of the review stage.
  static const int reviewQuestionCount = 15;

  /// Time per question of the speed stage.
  static const Duration speedTimeLimit = Duration(seconds: 10);

  /// Time per question of the boss fight.
  static const Duration bossTimeLimit = Duration(seconds: 8);

  /// Most questions of the boss fight.
  static const int bossQuestionCount = 20;

  /// The five stages of a table, in order.
  static const List<StageDefinition> tableStages = <StageDefinition>[
    StageDefinition(
      kind: StageKind.discovery,
      questionTypeIds: <String>[QuestionTypeIds.multipleChoice],
      selection: QuizSelection.inOrder,
    ),
    StageDefinition(
      kind: StageKind.training,
      questionTypeIds: <String>[
        QuestionTypeIds.multipleChoice,
        QuestionTypeIds.trueFalse,
      ],
      selection: QuizSelection.shuffled,
    ),
    StageDefinition(
      kind: StageKind.writing,
      questionTypeIds: <String>[
        QuestionTypeIds.typedAnswer,
        QuestionTypeIds.missingNumber,
      ],
      selection: QuizSelection.shuffled,
    ),
    StageDefinition(
      kind: StageKind.speed,
      questionTypeIds: _allTypes,
      selection: QuizSelection.shuffled,
      baseTimeLimit: speedTimeLimit,
    ),
    StageDefinition(
      kind: StageKind.boss,
      questionTypeIds: _allTypes,
      selection: QuizSelection.shuffled,
      questionCount: bossQuestionCount,
      baseTimeLimit: bossTimeLimit,
    ),
  ];

  /// The review stage after every group of 3 tables.
  static const StageDefinition review = StageDefinition(
    kind: StageKind.review,
    questionTypeIds: _allTypes,
    selection: QuizSelection.mastery,
    questionCount: reviewQuestionCount,
  );

  static const List<String> _allTypes = <String>[
    QuestionTypeIds.multipleChoice,
    QuestionTypeIds.typedAnswer,
    QuestionTypeIds.missingNumber,
    QuestionTypeIds.trueFalse,
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
