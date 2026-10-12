import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_time_schedule.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_submission.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_use_case.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';
import '../helpers/quiz_fixtures.dart';

const Duration _pairsTime = Duration(seconds: 12);

void main() {
  late FakeMasteryService mastery;
  late SubmitAnswerUseCase useCase;

  setUp(() {
    mastery = FakeMasteryService();
    useCase = buildSubmitAnswerUseCase(mastery: mastery);
  });

  Future<QuizRun> buildRunOf(
    String questionTypeId, {
    Duration? timeLimit = const Duration(seconds: 10),
  }) async {
    return (await buildQuizUseCase()(
      params: buildParams(
        itemKeys: tableKeys(3),
        questionTypeIds: <String>[questionTypeId],
        timeLimit: timeLimit,
      ),
    )).requireData;
  }

  Future<QuizSubmission> submit(QuizRun run, Answer? answer) async {
    return (await useCase(
      params: SubmitAnswerParams(
        run: run,
        answer: answer,
        answerTime: _pairsTime,
      ),
    )).requireData;
  }

  group('time per question', () {
    test('doubles the time of a match-pairs question', () async {
      // Act
      final QuizRun actualRun = await buildRunOf(QuestionTypeIds.matchPairs);
      // Assert
      expect(actualRun.timeFactors[QuestionTypeIds.matchPairs], 2);
      expect(actualRun.currentTimeLimit, const Duration(seconds: 20));
    });
    test('keeps the time of a find-the-operation question', () async {
      // Act
      final QuizRun actualRun = await buildRunOf(
        QuestionTypeIds.findOperation,
      );
      // Assert
      expect(actualRun.currentTimeLimit, const Duration(seconds: 10));
    });
    test('doubles the boss time and the relaxed time alike', () async {
      // Act
      final QuizRun actualBoss = await buildRunOf(
        QuestionTypeIds.matchPairs,
        timeLimit: const Duration(seconds: 8),
      );
      final QuizRun actualRelaxed = await buildRunOf(
        QuestionTypeIds.matchPairs,
        timeLimit: const Duration(seconds: 15),
      );
      // Assert
      expect(actualBoss.currentTimeLimit, const Duration(seconds: 16));
      expect(actualRelaxed.currentTimeLimit, const Duration(seconds: 30));
    });
    test('has no time without a timer', () async {
      // Act
      final QuizRun actualRun = await buildRunOf(
        QuestionTypeIds.matchPairs,
        timeLimit: null,
      );
      // Assert
      expect(actualRun.currentTimeLimit, isNull);
    });
    test('doubles a shrinking time too', () async {
      // Arrange
      final QuizRun inputRun = (await buildQuizUseCase()(
        params: BuildQuizParams(
          profileId: 'profile-1',
          domainId: 'multiplication',
          mode: buildParams(itemKeys: tableKeys(3)).mode,
          itemKeys: tableKeys(3),
          questionTypeIds: const <String>[QuestionTypeIds.matchPairs],
          timeLimit: const Duration(seconds: 10),
          timeSchedule: const QuizTimeSchedule(
            start: Duration(seconds: 10),
            step: Duration(seconds: 1),
            stepEvery: 1,
            floor: Duration(seconds: 4),
          ),
        ),
      )).requireData;
      // Act
      final QuizSubmission actualSubmission = await submit(
        inputRun,
        PairsAnswer(),
      );
      // Assert
      expect(actualSubmission.answeredTimeLimit, const Duration(seconds: 20));
      expect(
        actualSubmission.run.currentTimeLimit,
        const Duration(seconds: 18),
      );
    });
    test('gives the time of the question answered to its feedback', () async {
      // Arrange
      final QuizRun inputRun = await buildRunOf(QuestionTypeIds.matchPairs);
      // Act
      final QuizSubmission actualSubmission = await submit(
        inputRun,
        PairsAnswer(),
      );
      // Assert
      expect(actualSubmission.answeredTimeLimit, const Duration(seconds: 20));
    });
  });

  group('match the pairs in a quiz', () {
    test('scores one question and records each pair as right', () async {
      // Arrange
      final QuizRun inputRun = await buildRunOf(QuestionTypeIds.matchPairs);
      final Question inputQuestion = inputRun.currentTurn!.question;
      // Act
      final QuizSubmission actualSubmission = await submit(
        inputRun,
        PairsAnswer(),
      );
      // Assert
      expect(actualSubmission.answer.isCorrect, isTrue);
      expect(actualSubmission.answer.itemKey, inputQuestion.itemKey);
      expect(actualSubmission.run.answers, hasLength(1));
      expect(actualSubmission.run.correctCount, 1);
      expect(
        mastery.recordedAnswers.map((ItemAnswer answer) => answer.itemKey),
        inputQuestion.itemKeys,
      );
      for (final ItemAnswer recorded in mastery.recordedAnswers) {
        expect(recorded.isCorrect, isTrue);
        expect(recorded.questionTypeId, QuestionTypeIds.matchPairs);
        expect(recorded.answerTime, const Duration(seconds: 3));
        expect(recorded.isRetry, isFalse);
      }
    });
    test('records a missed pair once as a mistake on its fact', () async {
      // Arrange
      final QuizRun inputRun = await buildRunOf(QuestionTypeIds.matchPairs);
      final Question inputQuestion = inputRun.currentTurn!.question;
      final String inputMissed = inputQuestion.itemKeys.last;
      // Act
      final QuizSubmission actualSubmission = await submit(
        inputRun,
        PairsAnswer(missedItemKeys: <String>{inputMissed}),
      );
      // Assert
      expect(actualSubmission.answer.isCorrect, isFalse);
      expect(actualSubmission.answer.itemKey, inputMissed);
      expect(mastery.recordedAnswers, hasLength(4));
      for (final ItemAnswer recorded in mastery.recordedAnswers) {
        expect(recorded.isCorrect, recorded.itemKey != inputMissed);
      }
      expect(
        actualSubmission.run.queue
            .where((QuizTurn turn) => turn.isRetry)
            .map((QuizTurn turn) => turn.question.itemKey),
        <String>[inputMissed],
      );
    });
    test('names the first pair missed in display order', () async {
      // Arrange
      final QuizRun inputRun = await buildRunOf(QuestionTypeIds.matchPairs);
      final List<String> inputKeys = inputRun.currentTurn!.question.itemKeys;
      // Act
      final QuizSubmission actualSubmission = await submit(
        inputRun,
        PairsAnswer(missedItemKeys: <String>{inputKeys[3], inputKeys[1]}),
      );
      // Assert
      expect(actualSubmission.answer.itemKey, inputKeys[1]);
    });
    test('records every pair as missed when the time runs out', () async {
      // Arrange
      final QuizRun inputRun = await buildRunOf(QuestionTypeIds.matchPairs);
      final Question inputQuestion = inputRun.currentTurn!.question;
      // Act
      final QuizSubmission actualSubmission = await submit(inputRun, null);
      // Assert
      expect(actualSubmission.answer.isTimedOut, isTrue);
      expect(actualSubmission.answer.itemKey, inputQuestion.itemKey);
      expect(mastery.recordedAnswers, hasLength(4));
      expect(
        mastery.recordedAnswers.every((ItemAnswer answer) => !answer.isCorrect),
        isTrue,
      );
    });
    test('marks only the fact of a second chance as a retry', () async {
      // Arrange
      final QuizRun inputBuilt = await buildRunOf(QuestionTypeIds.matchPairs);
      final QuizRun inputRun = inputBuilt.copyWith(
        queue: <QuizTurn>[
          QuizTurn(question: inputBuilt.currentTurn!.question, isRetry: true),
        ],
      );
      final Question inputQuestion = inputRun.currentTurn!.question;
      // Act
      await submit(inputRun, PairsAnswer());
      // Assert
      expect(
        mastery.recordedAnswers
            .where((ItemAnswer answer) => answer.isRetry)
            .map((ItemAnswer answer) => answer.itemKey),
        <String>[inputQuestion.itemKey],
      );
    });
  });

  group('find the operation in a quiz', () {
    test('records its one fact', () async {
      // Arrange
      final QuizRun inputRun = await buildRunOf(
        QuestionTypeIds.findOperation,
      );
      final Question inputQuestion = inputRun.currentTurn!.question;
      // Act
      final QuizSubmission actualSubmission = await submit(
        inputRun,
        inputQuestion.expectedAnswer,
      );
      // Assert
      expect(actualSubmission.answer.isCorrect, isTrue);
      expect(mastery.recordedAnswers, hasLength(1));
      expect(mastery.recordedAnswers.single.itemKey, inputQuestion.itemKey);
      expect(mastery.recordedAnswers.single.answerTime, _pairsTime);
    });
  });
}
