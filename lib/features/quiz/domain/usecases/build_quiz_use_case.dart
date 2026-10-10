import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_generator.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';

/// Builds a quiz ready to be played.
///
/// The mastery engine chooses the items among those given, low boxes
/// more often, and the question types fit for each one. Fails with a
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
    final DataState<List<QuizItemPlan>> plans = await _mastery.planQuiz(
      request: QuizPlanRequest(
        profileId: params.profileId,
        domainId: domain.id,
        itemKeys: params.itemKeys,
        questionTypeIds: params.questionTypeIds,
        questionCount: params.questionCount ?? items.length,
      ),
    );
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
      queue: questions
          .map((Question question) => QuizTurn(question: question))
          .toList(),
    );
  }
}
