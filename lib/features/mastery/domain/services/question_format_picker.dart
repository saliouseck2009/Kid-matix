import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';

/// Picks the formats of the question of an item from its box.
///
/// Items in the first boxes are asked with answers to pick, the others
/// with answers to write, always among the formats that fit the item
/// (`LearningDomain.questionTypeIdsOf`).
final class QuestionFormatPicker {
  /// Creates the picker.
  const QuestionFormatPicker();

  /// Highest box whose items are asked with answers to pick first.
  static const int lastRecognizedBox = 2;

  /// Question types fit for an item of [box]: answers to pick up to
  /// [lastRecognizedBox], answers to write above; all of
  /// [questionTypeNatures] when none fits.
  List<String> questionTypesFor({
    required int box,
    required Map<String, AnswerNature> questionTypeNatures,
  }) {
    final AnswerNature preferred = box <= lastRecognizedBox
        ? AnswerNature.recognized
        : AnswerNature.produced;
    final List<String> fit = <String>[
      for (final MapEntry<String, AnswerNature> type
          in questionTypeNatures.entries)
        if (type.value == preferred) type.key,
    ];
    return fit.isEmpty ? questionTypeNatures.keys.toList() : fit;
  }

  /// The question of [item] of [domain] in [box], with the formats of the
  /// box among those of [questionTypeNatures] that fit the item.
  QuizItemPlan planFor({
    required LearningDomain domain,
    required LearningItem item,
    required int box,
    required Map<String, AnswerNature> questionTypeNatures,
  }) {
    return QuizItemPlan(
      itemKey: item.key,
      questionTypeIds: questionTypesFor(
        box: box,
        questionTypeNatures: fitFor(domain, item, questionTypeNatures),
      ),
    );
  }

  /// The question of the item of [progress] in [domain], with the formats
  /// of its box among those of [questionTypeNatures] that fit the item.
  QuizItemPlan planItem({
    required LearningDomain domain,
    required ItemProgressEntity progress,
    required Map<String, AnswerNature> questionTypeNatures,
  }) {
    final LearningItem? item = domain.findItem(progress.itemKey);
    return QuizItemPlan(
      itemKey: progress.itemKey,
      questionTypeIds: questionTypesFor(
        box: progress.box.clamp(0, MasteryPolicy.lastBox),
        questionTypeNatures: item == null
            ? questionTypeNatures
            : fitFor(domain, item, questionTypeNatures),
      ),
    );
  }

  /// The types of [questionTypeNatures] fit for [item] in [domain].
  Map<String, AnswerNature> fitFor(
    LearningDomain domain,
    LearningItem item,
    Map<String, AnswerNature> questionTypeNatures,
  ) {
    final List<String> itemTypeIds = domain.questionTypeIdsOf(item);
    return <String, AnswerNature>{
      for (final MapEntry<String, AnswerNature> type
          in questionTypeNatures.entries)
        if (itemTypeIds.contains(type.key)) type.key: type.value,
    };
  }
}
