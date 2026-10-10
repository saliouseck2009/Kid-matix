import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';

/// Chooses the items of a quiz and the format of each question.
///
/// Items are drawn with replacement, low boxes more often, and weighted
/// by the domain. Items in the first boxes are asked with answers to
/// pick, the others with answers to write.
final class QuizItemPlanner {
  /// Creates the planner.
  const QuizItemPlanner();

  /// Draw weight of an item by box: index 0 is box 0.
  static const List<int> boxDrawWeights = <int>[4, 5, 4, 3, 2, 1];

  /// Highest box whose items are asked with answers to pick first.
  static const int lastRecognizedBox = 2;

  /// Plans [count] questions among [items] of [domain]; none when
  /// [items] is empty.
  ///
  /// [progressByKey] gives the progress of the items already presented;
  /// [questionTypeNatures] the allowed question types with how each one
  /// collects the answer.
  List<QuizItemPlan> plan({
    required LearningDomain domain,
    required List<LearningItem> items,
    required Map<String, ItemProgressEntity> progressByKey,
    required Map<String, AnswerNature> questionTypeNatures,
    required int count,
    required RandomSource random,
  }) {
    if (items.isEmpty) return const <QuizItemPlan>[];
    final List<int> weights = <int>[
      for (final LearningItem item in items)
        boxDrawWeights[_boxOf(progressByKey, item)] * domain.drawWeightOf(item),
    ];
    final int total = weights.fold(0, (int sum, int weight) => sum + weight);
    return List<QuizItemPlan>.generate(count, (_) {
      final LearningItem item = items[_pickIndex(weights, total, random)];
      return QuizItemPlan(
        itemKey: item.key,
        questionTypeIds: questionTypesFor(
          box: _boxOf(progressByKey, item),
          questionTypeNatures: questionTypeNatures,
        ),
      );
    });
  }

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

  int _boxOf(Map<String, ItemProgressEntity> progressByKey, LearningItem item) {
    final int box = progressByKey[item.key]?.box ?? 0;
    return box.clamp(0, MasteryPolicy.lastBox);
  }

  int _pickIndex(List<int> weights, int total, RandomSource random) {
    int target = random.nextInt(total);
    for (int index = 0; index < weights.length; index++) {
      target -= weights[index];
      if (target < 0) return index;
    }
    return weights.length - 1;
  }
}
