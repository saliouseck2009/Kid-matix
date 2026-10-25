import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/frozen_question_generator.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_generator.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_type_registry.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_time_schedule.dart';
import 'package:kid_matix/core/quiz/seeded_draw.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';

/// Turns planned items into a [QuizRun] ready to be played.
///
/// The questions are built by the domain of each item, or by the frozen
/// generator for a seeded draw. Fails with a `ValidationException` when a
/// question cannot be built, such as an unknown question type.
final class QuizRunFactory {
  /// Creates the factory.
  const QuizRunFactory({
    required this._domains,
    required this._questionTypes,
    required this._generator,
    required this._random,
    required this._idGenerator,
    required this._clock,
    this._frozenGenerator = const FrozenQuestionGenerator(),
  });

  final DomainRegistry _domains;
  final QuestionTypeRegistry _questionTypes;
  final QuestionGenerator _generator;
  final RandomSource _random;
  final IdGenerator _idGenerator;
  final Clock _clock;
  final FrozenQuestionGenerator _frozenGenerator;

  /// The run of [params] asking [plans], every item of [domain].
  DataState<QuizRun> generate({
    required BuildQuizParams params,
    required LearningDomain domain,
    required List<QuizItemPlan> plans,
  }) {
    return _guard(
      params,
      () => _generator.generatePlanned(
        domain: domain,
        plans: plans,
        random: _random,
      ),
    );
  }

  /// The run of [params] asking [plans], each question built by the
  /// domain of its item; every item must belong to a known domain.
  DataState<QuizRun> generateMixed({
    required BuildQuizParams params,
    required List<QuizItemPlan> plans,
  }) {
    return _guard(params, () {
      return <Question>[
        for (final QuizItemPlan plan in plans)
          ..._generator.generatePlanned(
            domain: _domains.findByItemKey(plan.itemKey)!,
            plans: <QuizItemPlan>[plan],
            random: _random,
          ),
      ];
    });
  }

  /// The run of [params] asking the questions of [draw] in [domain],
  /// drawn without the player's mastery.
  DataState<QuizRun> generateSeeded({
    required BuildQuizParams params,
    required LearningDomain domain,
    required SeededDraw draw,
  }) {
    return _guard(
      params,
      () => _frozenGenerator.generate(
        domain: domain,
        itemKeys: params.itemKeys,
        questionTypeIds: params.questionTypeIds,
        questionCount: params.questionCount ?? params.itemKeys.length,
        draw: draw,
      ),
    );
  }

  /// A new run of [params] asking [questions], started now.
  QuizRun createRun({
    required BuildQuizParams params,
    required List<Question> questions,
  }) {
    final Duration? timeLimit = params.timeLimit;
    final QuizTimeSchedule? schedule = timeLimit == null
        ? null
        : params.timeSchedule?.scaledTo(timeLimit);
    return QuizRun(
      sessionId: _idGenerator.generateId(),
      profileId: params.profileId,
      domainId: params.domainId,
      mode: params.mode,
      startedAt: _clock.now(),
      scoredQuestionCount: questions.length,
      questionTypeIds: params.questionTypeIds,
      timeLimit: timeLimit,
      totalTimeLimit: params.totalTimeLimit,
      lives: params.lives,
      timeSchedule: schedule,
      timeFactors: <String, int>{
        for (final String id in params.questionTypeIds)
          if (_questionTypes.find(id) case final QuestionType type)
            id: type.timeFactor,
      },
      sourceKey: params.sourceKey,
      boss: params.isBossFight ? const BossFight() : null,
      queue: questions
          .map((Question question) => QuizTurn(question: question))
          .toList(),
    );
  }

  DataState<QuizRun> _guard(
    BuildQuizParams params,
    List<Question> Function() build,
  ) {
    try {
      return DataSuccess<QuizRun>(
        createRun(params: params, questions: build()),
      );
    } on ArgumentError catch (error) {
      return DataFailed<QuizRun>(ValidationException(message: '$error'));
    }
  }
}
