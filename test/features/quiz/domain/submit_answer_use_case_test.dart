import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_submission.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_use_case.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/quiz_fixtures.dart';

const Duration _quick = Duration(seconds: 2);
const Duration _slow = Duration(seconds: 5);

void main() {
  late SubmitAnswerUseCase useCase;

  setUp(() => useCase = buildSubmitAnswerUseCase());

  Future<QuizSubmission> answer(
    QuizRun run, {
    required bool isRight,
    Duration time = _quick,
    bool timesOut = false,
  }) async {
    final Answer expected = run.currentTurn!.question.expectedAnswer;
    final Answer given = isRight ? expected : const NumberAnswer(-1);
    return (await useCase(
      params: SubmitAnswerParams(
        run: run,
        answer: timesOut ? null : given,
        answerTime: time,
      ),
    )).requireData;
  }

  List<String> queuedKeys(QuizRun run) {
    return run.queue.map((QuizTurn turn) => turn.question.itemKey).toList();
  }

  group('judging an answer', () {
    test('records a quick right answer as "Éclair"', () async {
      // Arrange
      final QuizRun inputRun = await buildRun(tableKeys(5));
      // Act
      final QuizSubmission actualSubmission = await answer(
        inputRun,
        isRight: true,
      );
      // Assert
      expect(actualSubmission.answer.isCorrect, isTrue);
      expect(actualSubmission.answer.isLightning, isTrue);
      expect(actualSubmission.answer.answerTime, _quick);
      expect(actualSubmission.run.answers, hasLength(1));
      expect(actualSubmission.run.queue, hasLength(9));
      expect(actualSubmission.run.correctCount, 1);
    });
    test('gives no "Éclair" from 3 seconds on', () async {
      // Arrange
      final QuizRun inputRun = await buildRun(tableKeys(5));
      // Act
      final QuizSubmission actualSubmission = await answer(
        inputRun,
        isRight: true,
        time: QuizAnswerEntity.lightningLimit,
      );
      // Assert
      expect(actualSubmission.answer.isCorrect, isTrue);
      expect(actualSubmission.answer.isLightning, isFalse);
    });
    test('counts a timed-out question as a mistake', () async {
      // Arrange
      final QuizRun inputRun = await buildRun(tableKeys(5));
      // Act
      final QuizSubmission actualSubmission = await answer(
        inputRun,
        isRight: false,
        time: _slow,
        timesOut: true,
      );
      // Assert
      expect(actualSubmission.answer.isCorrect, isFalse);
      expect(actualSubmission.answer.isTimedOut, isTrue);
    });
    test('refuses an answer once the quiz is over', () async {
      // Arrange
      final QuizRun inputRun = (await buildRun(<String>['mul:5x1']))
          .copyWith(queue: <QuizTurn>[]);
      // Act
      final AppException? actualException = (await useCase(
        params: SubmitAnswerParams(
          run: inputRun,
          answer: const NumberAnswer(5),
          answerTime: _quick,
        ),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<ValidationException>());
    });
  });

  group('second chance of a missed fact', () {
    test('asks a missed fact again 3 questions later', () async {
      // Arrange
      final QuizRun inputRun = await buildRun(tableKeys(5));
      // Act
      final QuizSubmission actualSubmission = await answer(
        inputRun,
        isRight: false,
      );
      // Assert
      expect(queuedKeys(actualSubmission.run).take(4), <String>[
        'mul:5x2',
        'mul:5x3',
        'mul:5x1',
        'mul:5x4',
      ]);
      expect(actualSubmission.run.queue[2].isRetry, isTrue);
      expect(actualSubmission.run.turnCount, 11);
    });
    test('also gives a second chance after a timed-out question', () async {
      // Arrange
      final QuizRun inputRun = await buildRun(tableKeys(5));
      // Act
      final QuizSubmission actualSubmission = await answer(
        inputRun,
        isRight: false,
        timesOut: true,
      );
      // Assert
      expect(actualSubmission.run.queue[2].isRetry, isTrue);
    });
    test('gives a second chance only once', () async {
      // Arrange
      QuizRun run = await buildRun(tableKeys(5));
      run = (await answer(run, isRight: false)).run;
      run = (await answer(run, isRight: true)).run;
      run = (await answer(run, isRight: true)).run;
      // Act
      final QuizSubmission actualSubmission = await answer(
        run,
        isRight: false,
      );
      // Assert
      expect(actualSubmission.turn.isRetry, isTrue);
      expect(actualSubmission.answer.isRetry, isTrue);
      expect(
        actualSubmission.run.queue.where((QuizTurn turn) => turn.isRetry),
        isEmpty,
      );
    });
    test('puts the second chance last near the end of the quiz', () async {
      // Arrange
      QuizRun run = await buildRun(<String>['mul:5x1', 'mul:5x2']);
      run = (await answer(run, isRight: true)).run;
      // Act
      final QuizSubmission actualSubmission = await answer(
        run,
        isRight: false,
      );
      // Assert
      expect(queuedKeys(actualSubmission.run), <String>['mul:5x2']);
      expect(actualSubmission.run.queue.single.isRetry, isTrue);
    });
    test('does not count the second chance in the score', () async {
      // Arrange
      QuizRun run = await buildRun(<String>['mul:5x1', 'mul:5x2']);
      run = (await answer(run, isRight: false)).run;
      run = (await answer(run, isRight: true)).run;
      // Act
      final QuizRun actualRun = (await answer(run, isRight: true)).run;
      // Assert
      expect(actualRun.isFinished, isTrue);
      expect(actualRun.answers, hasLength(3));
      expect(actualRun.correctCount, 1);
    });
  });
}
