import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/quiz_item_planner.dart';
import 'package:kid_matix/features/mastery/domain/services/review_item_selector.dart';

/// Plans a review that mixes the items of several domains, such as the
/// daily review.
///
/// The items to review are chosen once across every domain, so a due fact
/// is never dropped for lack of room; each question then gets the formats
/// of its own domain. A domain with no allowed format is left out.
final class MixedQuizPlanner {
  /// Creates the planner over the [domains] of the app.
  const MixedQuizPlanner({
    required this._domains,
    this._selector = const ReviewItemSelector(),
    this._planner = const QuizItemPlanner(),
  });

  final DomainRegistry _domains;
  final ReviewItemSelector _selector;
  final QuizItemPlanner _planner;

  /// At most [count] questions among the [progress] of the items of
  /// [itemKeys], due first, at [now]. [natures] gives, per domain id, the
  /// allowed question types with how each one collects the answer; an item
  /// of a domain without any is left out.
  List<QuizItemPlan> planReview({
    required List<String> itemKeys,
    required List<ItemProgressEntity> progress,
    required Map<String, Map<String, AnswerNature>> natures,
    required int count,
    required DateTime now,
    required RandomSource random,
  }) {
    final Set<String> allowed = itemKeys.toSet();
    final List<ItemProgressEntity> candidates = <ItemProgressEntity>[
      for (final ItemProgressEntity item in progress)
        if (allowed.contains(item.itemKey) && _canAsk(item.itemKey, natures))
          item,
    ];
    final List<ItemProgressEntity> chosen = _selector.select(
      progress: candidates,
      now: now,
      count: count,
    );
    return <QuizItemPlan>[
      for (final ItemProgressEntity item in random.shuffled(chosen))
        _planner.planItem(
          domain: _domains.findByItemKey(item.itemKey)!,
          progress: item,
          questionTypeNatures:
              natures[_domains.findByItemKey(item.itemKey)!.id]!,
        ),
    ];
  }

  bool _canAsk(String itemKey, Map<String, Map<String, AnswerNature>> natures) {
    final LearningDomain? domain = _domains.findByItemKey(itemKey);
    return domain != null && (natures[domain.id]?.isNotEmpty ?? false);
  }
}
