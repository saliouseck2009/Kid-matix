import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_generator.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';

/// Builds a quiz ready to be played.
///
/// By default the mastery engine chooses the items among those given,
/// missed facts first, and the question types fit for each one; a quiz
/// can also ask every item once, in order or shuffled. Fails with a
/// `ValidationException` when the domain, an item or every question type
/// is unknown, or when no item is given.
class BuildQuizUseCase implements UseCase<DataState<QuizRun>, BuildQuizParams> {
  /// Creates the use case.
  const BuildQuizUseCase({
    required this._domains,
    required this._mastery,
    required this._generator,
    required this._random,
    required this._idGenerator,
    required this._clock,
  });

  final DomainRegistry _domains;
  final MasteryService _mastery;
  final QuestionGenerator _generator;
  final RandomSource _random;
  final IdGenerator _idGenerator;
  final Clock _clock;

  @override
  Future<DataState<QuizRun>> call({required BuildQuizParams params}) async {
    final LearningDomain? domain = _domains.find(params.domainId);
    final List<LearningItem>? items = domain == null
        ? null
        : _findItems(domain, params.itemKeys);
    if (domain == null || items == null || items.isEmpty) {
      return const DataFailed<QuizRun>(
        ValidationException(message: 'Unknown domain or items.'),
      );
    }
    final DataState<List<QuizItemPlan>> main = await _plan(params, items);
    final DataState<List<QuizItemPlan>> plans =
        main is DataSuccess<List<QuizItemPlan>>
        ? await _addFollowUp(params, main.data)
        : main;
    return switch (plans) {
      DataSuccess<List<QuizItemPlan>>(:final data) => _generate(
        params,
        domain,
        data,
      ),
      DataFailed<List<QuizItemPlan>>(:final exception) => DataFailed<QuizRun>(
        exception,
      ),
    };
  }

  /// The items to ask with their types: drawn by the mastery engine, or
  /// every item once in the given or a random order.
  Future<DataState<List<QuizItemPlan>>> _plan(
    BuildQuizParams params,
    List<LearningItem> items,
  ) async {
    final List<LearningItem> ordered = switch (params.selection) {
      QuizSelection.mastery => const <LearningItem>[],
      QuizSelection.inOrder => items,
      QuizSelection.shuffled => _random.shuffled(items),
    };
    if (params.selection != QuizSelection.mastery) {
      return DataSuccess<List<QuizItemPlan>>(<QuizItemPlan>[
        for (final LearningItem item in ordered)
          QuizItemPlan(
            itemKey: item.key,
            questionTypeIds: params.questionTypeIds,
          ),
      ]);
    }
    return _mastery.planQuiz(
      request: QuizPlanRequest(
        profileId: params.profileId,
        domainId: params.domainId,
        itemKeys: params.itemKeys,
        questionTypeIds: params.questionTypeIds,
        questionCount: params.questionCount ?? items.length,
      ),
    );
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

  DataState<QuizRun> _generate(
    BuildQuizParams params,
    LearningDomain domain,
    List<QuizItemPlan> plans,
  ) {
    try {
      final List<Question> questions = _generator.generatePlanned(
        domain: domain,
        plans: plans,
        random: _random,
      );
      return DataSuccess<QuizRun>(_createRun(params, questions));
    } on ArgumentError catch (error) {
      return DataFailed<QuizRun>(ValidationException(message: '$error'));
    }
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

  QuizRun _createRun(BuildQuizParams params, List<Question> questions) {
    return QuizRun(
      sessionId: _idGenerator.generateId(),
      profileId: params.profileId,
      domainId: params.domainId,
      mode: params.mode,
      startedAt: _clock.now(),
      scoredQuestionCount: questions.length,
      questionTypeIds: params.questionTypeIds,
      timeLimit: params.timeLimit,
      sourceKey: params.sourceKey,
      boss: params.isBossFight ? const BossFight() : null,
      queue: questions
          .map((Question question) => QuizTurn(question: question))
          .toList(),
    );
  }
}
