import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_type_registry.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';
import 'package:kid_matix/features/mastery/domain/services/quiz_item_planner.dart';

/// Chooses the items of a quiz from the player's progress, with the
/// question types fit for each one: a weighted draw, the items to review
/// for a review, or the monsters for a monster hunt.
///
/// Fails with a `ValidationException` when the domain, an item or every
/// question type is unknown.
class PlanQuizUseCase
    implements UseCase<DataState<List<QuizItemPlan>>, QuizPlanRequest> {
  /// Creates the use case.
  const PlanQuizUseCase({
    required this._repository,
    required this._domains,
    required this._questionTypes,
    required this._random,
    required this._clock,
    this._planner = const QuizItemPlanner(),
  });

  final ItemProgressRepository _repository;
  final DomainRegistry _domains;
  final QuestionTypeRegistry _questionTypes;
  final RandomSource _random;
  final Clock _clock;
  final QuizItemPlanner _planner;

  @override
  Future<DataState<List<QuizItemPlan>>> call({
    required QuizPlanRequest params,
  }) async {
    final LearningDomain? domain = _domains.find(params.domainId);
    final List<LearningItem?> items = <LearningItem?>[
      for (final String key in params.itemKeys) domain?.findItem(key),
    ];
    final Map<String, AnswerNature> natures = _naturesOf(params, domain);
    if (domain == null || items.contains(null) || natures.isEmpty) {
      return const DataFailed<List<QuizItemPlan>>(
        ValidationException(message: 'Unknown domain, items or types.'),
      );
    }
    final DataState<List<ItemProgressEntity>> progress = await _repository
        .getProgress(profileId: params.profileId, domainId: domain.id);
    return switch (progress) {
      DataSuccess<List<ItemProgressEntity>>(:final data) =>
        DataSuccess<List<QuizItemPlan>>(
          _planItems(
            params: params,
            domain: domain,
            items: items.whereType<LearningItem>().toList(),
            progressByKey: <String, ItemProgressEntity>{
              for (final ItemProgressEntity item in data) item.itemKey: item,
            },
            natures: natures,
          ),
        ),
      DataFailed<List<ItemProgressEntity>>(:final exception) =>
        DataFailed<List<QuizItemPlan>>(exception),
    };
  }

  List<QuizItemPlan> _planItems({
    required QuizPlanRequest params,
    required LearningDomain domain,
    required List<LearningItem> items,
    required Map<String, ItemProgressEntity> progressByKey,
    required Map<String, AnswerNature> natures,
  }) {
    return switch (params.selection) {
      QuizSelection.review => _planner.planReview(
        domain: domain,
        items: items,
        progressByKey: progressByKey,
        questionTypeNatures: natures,
        count: params.questionCount,
        now: _clock.now(),
        random: _random,
      ),
      QuizSelection.monsterHunt => _planner.planMonsterHunt(
        domain: domain,
        items: items,
        progressByKey: progressByKey,
        questionTypeNatures: natures,
        count: params.questionCount,
        now: _clock.now(),
        random: _random,
      ),
      QuizSelection.mastery ||
      QuizSelection.inOrder ||
      QuizSelection.shuffled => _planner.plan(
        domain: domain,
        items: items,
        progressByKey: progressByKey,
        questionTypeNatures: natures,
        count: params.questionCount,
        random: _random,
      ),
    };
  }

  /// The allowed question types that [domain] supports, with how each one
  /// collects the answer.
  Map<String, AnswerNature> _naturesOf(
    QuizPlanRequest params,
    LearningDomain? domain,
  ) {
    if (domain == null) return const <String, AnswerNature>{};
    return <String, AnswerNature>{
      for (final String id in params.questionTypeIds)
        if (domain.questionTypeIds.contains(id))
          if (_questionTypes.find(id) case final QuestionType type)
            id: type.answerNature,
    };
  }
}
