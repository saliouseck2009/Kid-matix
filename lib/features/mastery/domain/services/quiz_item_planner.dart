import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';
import 'package:kid_matix/features/mastery/domain/services/monster_hunt_selector.dart';
import 'package:kid_matix/features/mastery/domain/services/review_item_selector.dart';

/// Chooses the items of a quiz and the format of each question.
///
/// Every item to review (box 1) is asked once first, so missed facts
/// come back at the next quiz; the other questions are drawn with
/// replacement, low boxes more often, and weighted by the domain. The
/// order is then shuffled. Items in the first boxes are asked with
/// answers to pick, the others with answers to write, always among the
/// formats that fit the item (`LearningDomain.questionTypeIdsOf`).
///
/// A review asks instead the items [ReviewItemSelector] chooses, each
/// once, and a monster hunt those [MonsterHuntSelector] chooses, with the
/// same formats.
final class QuizItemPlanner {
  /// Creates the planner.
  const QuizItemPlanner({
    this._selector = const ReviewItemSelector(),
    this._hunt = const MonsterHuntSelector(),
  });

  final ReviewItemSelector _selector;
  final MonsterHuntSelector _hunt;

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
    final List<LearningItem> chosen = <LearningItem>[
      ...items
          .where(
            (LearningItem item) =>
                _boxOf(progressByKey, item) == MasteryPolicy.firstBox,
          )
          .take(count),
    ];
    while (chosen.length < count) {
      chosen.add(items[_pickIndex(weights, total, random)]);
    }
    return random
        .shuffled(chosen)
        .map(
          (LearningItem item) => QuizItemPlan(
            itemKey: item.key,
            questionTypeIds: questionTypesFor(
              box: _boxOf(progressByKey, item),
              questionTypeNatures: _fitFor(
                domain,
                item,
                questionTypeNatures,
              ),
            ),
          ),
        )
        .toList();
  }

  /// Plans a review of at most [count] questions among [items] at [now]:
  /// the due items first, then the weakest, each once and in a random
  /// order. Items never presented are left out, so the review is empty
  /// for a player who has seen none.
  List<QuizItemPlan> planReview({
    required LearningDomain domain,
    required List<LearningItem> items,
    required Map<String, ItemProgressEntity> progressByKey,
    required Map<String, AnswerNature> questionTypeNatures,
    required int count,
    required DateTime now,
    required RandomSource random,
  }) {
    final List<ItemProgressEntity> chosen = _selector.select(
      progress: <ItemProgressEntity>[
        for (final LearningItem item in items) ?progressByKey[item.key],
      ],
      now: now,
      count: count,
    );
    return _planEach(domain, random.shuffled(chosen), questionTypeNatures);
  }

  /// Plans a monster hunt of at most [count] questions among [items] at
  /// [now]: each monster twice, never twice in a row, completed with the
  /// items a review would pick. Items never presented are left out.
  List<QuizItemPlan> planMonsterHunt({
    required LearningDomain domain,
    required List<LearningItem> items,
    required Map<String, ItemProgressEntity> progressByKey,
    required Map<String, AnswerNature> questionTypeNatures,
    required int count,
    required DateTime now,
    required RandomSource random,
  }) {
    final List<ItemProgressEntity> chosen = _hunt.select(
      progress: <ItemProgressEntity>[
        for (final LearningItem item in items) ?progressByKey[item.key],
      ],
      now: now,
      count: count,
      random: random,
    );
    return _planEach(domain, chosen, questionTypeNatures);
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

  /// One question per item of [chosen], in order, with the formats of
  /// its box.
  List<QuizItemPlan> _planEach(
    LearningDomain domain,
    List<ItemProgressEntity> chosen,
    Map<String, AnswerNature> questionTypeNatures,
  ) {
    return chosen
        .map(
          (ItemProgressEntity progress) => planItem(
            domain: domain,
            progress: progress,
            questionTypeNatures: questionTypeNatures,
          ),
        )
        .toList();
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
            : _fitFor(domain, item, questionTypeNatures),
      ),
    );
  }

  /// The types of [questionTypeNatures] fit for [item] in [domain].
  Map<String, AnswerNature> _fitFor(
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
