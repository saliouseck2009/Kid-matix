import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/seeded_draw.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/services/quiz_run_factory.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';

/// Builds a quiz ready to be played.
///
/// By default the mastery engine chooses the items among those given,
/// missed facts first, and the question types fit for each one; a quiz
/// can also ask every item once, in order or shuffled, the items to
/// review, or the player's monsters. A quiz with a seeded draw asks the
/// questions of its frozen generator, the same on every phone. Fails with
/// a `ValidationException` when the domain, an item or every question
/// type is unknown, or when no item is given, and with a
/// `NotFoundException` when there is no question to ask, such as a review
/// before any item was seen.
class BuildQuizUseCase implements UseCase<DataState<QuizRun>, BuildQuizParams> {
  /// Creates the use case.
  const BuildQuizUseCase({
    required this._domains,
    required this._mastery,
    required this._random,
    required this._runs,
  });

  final DomainRegistry _domains;
  final MasteryService _mastery;
  final RandomSource _random;
  final QuizRunFactory _runs;

  @override
  Future<DataState<QuizRun>> call({required BuildQuizParams params}) async {
    if (params.domainId == LearningDomainIds.mixed) return _buildMixed(params);
    final LearningDomain? domain = _domains.find(params.domainId);
    final List<LearningItem>? items = domain == null
        ? null
        : _findItems(domain, params.itemKeys);
    if (domain == null || items == null || items.isEmpty) {
      return const DataFailed<QuizRun>(
        ValidationException(message: 'Unknown domain or items.'),
      );
    }
    final SeededDraw? draw = params.seededDraw;
    if (draw != null) {
      return _runs.generateSeeded(params: params, domain: domain, draw: draw);
    }
    final DataState<List<QuizItemPlan>> main = await _plan(
      params,
      params.domainId,
      items,
    );
    final DataState<List<QuizItemPlan>> plans =
        main is DataSuccess<List<QuizItemPlan>>
        ? await _addFollowUp(params, main.data)
        : main;
    return _toRun(
      plans,
      (List<QuizItemPlan> data) =>
          _runs.generate(params: params, domain: domain, plans: data),
    );
  }

  /// The items to ask with their types: drawn or picked for a review or a
  /// monster hunt by the mastery engine, or every item once in the given
  /// or a random order.
  Future<DataState<List<QuizItemPlan>>> _plan(
    BuildQuizParams params,
    String domainId,
    List<LearningItem> items,
  ) async {
    return switch (params.selection) {
      QuizSelection.mastery ||
      QuizSelection.review ||
      QuizSelection.monsterHunt => await _mastery.planQuiz(
        request: QuizPlanRequest(
          profileId: params.profileId,
          domainId: domainId,
          itemKeys: items.map((LearningItem item) => item.key).toList(),
          questionTypeIds: params.questionTypeIds,
          questionCount: params.questionCount ?? items.length,
          selection: params.selection,
        ),
      ),
      QuizSelection.inOrder => _askEach(params, items),
      QuizSelection.shuffled => _askEach(params, _random.shuffled(items)),
    };
  }

  /// A quiz that mixes the items of several domains, such as the daily
  /// review: the mastery engine plans them across every domain at once and
  /// every question is built by the domain of its item. It has no
  /// follow-up questions and no seeded draw.
  Future<DataState<QuizRun>> _buildMixed(BuildQuizParams params) async {
    final bool isKnown =
        params.itemKeys.isNotEmpty &&
        params.itemKeys.every(
          (String key) => _domains.findByItemKey(key) != null,
        );
    if (!isKnown || params.seededDraw != null) {
      return const DataFailed<QuizRun>(
        ValidationException(message: 'Unknown items for a mixed quiz.'),
      );
    }
    final DataState<List<QuizItemPlan>> plans = await _mastery.planQuiz(
      request: QuizPlanRequest(
        profileId: params.profileId,
        domainId: params.domainId,
        itemKeys: params.itemKeys,
        questionTypeIds: params.questionTypeIds,
        questionCount: params.questionCount ?? params.itemKeys.length,
        selection: params.selection,
      ),
    );
    return _toRun(
      plans,
      (List<QuizItemPlan> data) =>
          _runs.generateMixed(params: params, plans: data),
    );
  }

  /// The run [generate] builds from [plans], or why there is none.
  DataState<QuizRun> _toRun(
    DataState<List<QuizItemPlan>> plans,
    DataState<QuizRun> Function(List<QuizItemPlan> plans) generate,
  ) {
    return switch (plans) {
      DataSuccess<List<QuizItemPlan>>(:final data) when data.isEmpty =>
        const DataFailed<QuizRun>(
          NotFoundException(message: 'No question to ask.'),
        ),
      DataSuccess<List<QuizItemPlan>>(:final data) => generate(data),
      DataFailed<List<QuizItemPlan>>(:final exception) => DataFailed<QuizRun>(
        exception,
      ),
    };
  }

  DataState<List<QuizItemPlan>> _askEach(
    BuildQuizParams params,
    List<LearningItem> items,
  ) {
    return DataSuccess<List<QuizItemPlan>>(<QuizItemPlan>[
      for (final LearningItem item in items)
        QuizItemPlan(
          itemKey: item.key,
          questionTypeIds: params.questionTypeIds,
        ),
    ]);
  }

  /// [plans] followed by up to `followUpQuestionCount` of the weakest
  /// follow-up items, each once.
  Future<DataState<List<QuizItemPlan>>> _addFollowUp(
    BuildQuizParams params,
    List<QuizItemPlan> plans,
  ) async {
    if (params.followUpQuestionCount <= 0 || params.followUpItemKeys.isEmpty) {
      return DataSuccess<List<QuizItemPlan>>(plans);
    }
    final DataState<List<QuizItemPlan>> drawn = await _mastery.planQuiz(
      request: QuizPlanRequest(
        profileId: params.profileId,
        domainId: params.domainId,
        itemKeys: params.followUpItemKeys,
        questionTypeIds: params.questionTypeIds,
        questionCount: params.followUpQuestionCount,
      ),
    );
    if (drawn is! DataSuccess<List<QuizItemPlan>>) return drawn;
    final Set<String> seen = <String>{};
    return DataSuccess<List<QuizItemPlan>>(<QuizItemPlan>[
      ...plans,
      ...drawn.data.where((QuizItemPlan plan) => seen.add(plan.itemKey)),
    ]);
  }

  List<LearningItem>? _findItems(LearningDomain domain, List<String> keys) {
    final List<LearningItem> items = <LearningItem>[];
    for (final String key in keys) {
      final LearningItem? item = domain.findItem(key);
      if (item == null) return null;
      items.add(item);
    }
    return items;
  }
}
