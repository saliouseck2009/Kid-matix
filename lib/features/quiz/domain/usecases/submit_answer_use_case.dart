import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_generator.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_type_registry.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_submission.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_params.dart';

/// Judges the answer to the current question, records it in the mastery
/// of its item and moves the quiz on.
///
/// The progress is saved at each answer, so a quiz left or an app closed
/// midway loses nothing; a progress that cannot be saved is logged and
/// never stops the game.
/// A missed fact comes back 3 questions later, once per session, with a
/// question drawn again; that second chance does not count in the score,
/// except in a boss fight. In a boss fight every right answer hits the
/// boss, and the fight ends when it falls or after its last question.
/// Fails with a `ValidationException` when the quiz is over or its domain
/// or question type is unknown.
class SubmitAnswerUseCase
    implements UseCase<DataState<QuizSubmission>, SubmitAnswerParams> {
  /// Creates the use case.
  const SubmitAnswerUseCase({
    required this._questionTypes,
    required this._domains,
    required this._mastery,
    required this._generator,
    required this._random,
  });

  /// Questions asked between a missed fact and its second chance.
  static const int retryDelay = 2;

  final QuestionTypeRegistry _questionTypes;
  static const String _logName = 'quiz';

  final DomainRegistry _domains;
  final MasteryService _mastery;
  final QuestionGenerator _generator;
  final RandomSource _random;

  @override
  Future<DataState<QuizSubmission>> call({
    required SubmitAnswerParams params,
  }) async {
    final QuizRun run = params.run;
    final QuizTurn? turn = run.currentTurn;
    final QuestionType? type = turn == null
        ? null
        : _questionTypes.find(turn.question.questionTypeId);
    final LearningDomain? domain = _domains.find(run.domainId);
    if (turn == null || type == null || domain == null) {
      return const DataFailed<QuizSubmission>(
        ValidationException(message: 'No question to answer.'),
      );
    }
    final QuizAnswerEntity answer = _judge(turn, type, params);
    await _record(run, answer);
    final List<QuizAnswerEntity> answers = <QuizAnswerEntity>[
      ...run.answers,
      answer,
    ];
    final BossFight? boss = run.boss?.hit(answer);
    final bool isFightOver =
        boss != null &&
        (boss.isDefeated || answers.length >= BossFight.maxQuestions);
    final List<QuizTurn> queue = isFightOver
        ? const <QuizTurn>[]
        : <QuizTurn>[...run.queue.skip(1)];
    if (!isFightOver && _needsRetry(run, turn, answer)) {
      queue.insert(
        queue.length < retryDelay ? queue.length : retryDelay,
        _buildRetry(domain, run, turn.question),
      );
    }
    return DataSuccess<QuizSubmission>(
      QuizSubmission(
        turn: turn,
        answer: answer,
        run: run.copyWith(queue: queue, answers: answers, boss: boss),
      ),
    );
  }

  QuizAnswerEntity _judge(
    QuizTurn turn,
    QuestionType type,
    SubmitAnswerParams params,
  ) {
    final Question question = turn.question;
    final bool isCorrect =
        params.answer != null &&
        type.isCorrect(question: question, answer: params.answer!);
    return QuizAnswerEntity(
      itemKey: question.itemKey,
      questionTypeId: question.questionTypeId,
      isCorrect: isCorrect,
      isTimedOut: params.answer == null,
      isRetry: turn.isRetry,
      answerTime: params.answerTime,
    );
  }

  Future<void> _record(QuizRun run, QuizAnswerEntity answer) async {
    final DataState<void> recorded = await _mastery.recordAnswer(
      answer: ItemAnswer(
        profileId: run.profileId,
        domainId: run.domainId,
        itemKey: answer.itemKey,
        questionTypeId: answer.questionTypeId,
        isCorrect: answer.isCorrect,
        answerTime: answer.answerTime,
        isRetry: answer.isRetry,
      ),
    );
    if (recorded case DataFailed<void>(:final exception)) {
      log('Progress not recorded', name: _logName, error: exception);
    }
  }

  bool _needsRetry(QuizRun run, QuizTurn turn, QuizAnswerEntity answer) {
    return !answer.isCorrect &&
        !turn.isRetry &&
        !run.hasRetry(turn.question.itemKey);
  }

  QuizTurn _buildRetry(LearningDomain domain, QuizRun run, Question missed) {
    final LearningItem item = domain.findItem(missed.itemKey)!;
    final Question question = _generator
        .generate(
          domain: domain,
          items: <LearningItem>[item],
          questionTypeIds: run.questionTypeIds,
          random: _random,
        )
        .single;
    return QuizTurn(question: question, isRetry: true);
  }
}
