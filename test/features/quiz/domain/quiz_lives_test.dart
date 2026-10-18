import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_time_schedule.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_submission.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_use_case.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/quiz_fixtures.dart';

const QuizTimeSchedule _schedule = QuizTimeSchedule(
  start: Duration(seconds: 10),
  step: Duration(milliseconds: 500),
  stepEvery: 5,
  floor: Duration(seconds: 4),
);

BuildQuizParams _livesParams({Duration? timeLimit = _start}) {
  return BuildQuizParams(
    profileId: 'profile-1',
    domainId: MultiplicationDomain.domainId,
    mode: QuizMode.survival,
    itemKeys: tableKeys(5),
    questionTypeIds: const <String>[QuestionTypeIds.multipleChoice],
    questionCount: 40,
    timeLimit: timeLimit,
    lives: 3,
    timeSchedule: _schedule,
  );
}

const Duration _start = Duration(seconds: 10);

void main() {
  late SubmitAnswerUseCase submit;

  setUp(() {
    submit = buildSubmitAnswerUseCase();
  });

  Future<QuizRun> buildLivesRun({Duration? timeLimit = _start}) async {
    return (await buildQuizUseCase()(
      params: _livesParams(timeLimit: timeLimit),
    )).requireData;
  }

  Future<QuizSubmission> answer(QuizRun run, {required bool isRight}) async {
    final Answer expected = run.currentTurn!.question.expectedAnswer;
    return (await submit(
      params: SubmitAnswerParams(
        run: run,
        answer: isRight ? expected : null,
        answerTime: const Duration(seconds: 2),
      ),
    )).requireData;
  }

  Future<QuizRun> play(QuizRun run, List<bool> rights) async {
    QuizRun current = run;
    for (final bool isRight in rights) {
      current = (await answer(current, isRight: isRight)).run;
    }
    return current;
  }

  group('A quiz with lives', () {
    test('starts with every life and goes on by itself', () async {
      // Act
      final QuizRun actualRun = await buildLivesRun();
      // Assert
      expect(actualRun.lives, 3);
      expect(actualRun.livesLeft, 3);
      expect(actualRun.isNonStop, isTrue);
      expect(actualRun.isAgainstTheClock, isFalse);
      expect(actualRun.timeSchedule, _schedule);
    });
    test('loses a life at each mistake, a time-out included', () async {
      // Arrange
      final QuizRun inputRun = await buildLivesRun();
      // Act
      final QuizRun actualRun = await play(inputRun, <bool>[true, false]);
      // Assert
      expect(actualRun.livesLeft, 2);
      expect(actualRun.answers.last.isTimedOut, isTrue);
    });
    test('never brings a missed fact back', () async {
      // Arrange
      final QuizRun inputRun = await buildLivesRun();
      // Act
      final QuizRun actualRun = await play(inputRun, <bool>[false]);
      // Assert
      expect(actualRun.queue.where((QuizTurn turn) => turn.isRetry), isEmpty);
      expect(actualRun.queue, hasLength(inputRun.queue.length - 1));
    });
    test('ends at the third mistake', () async {
      // Arrange
      final QuizRun inputRun = await buildLivesRun();
      // Act
      final QuizRun actualBefore = await play(inputRun, <bool>[
        false,
        true,
        false,
      ]);
      final QuizRun actualAfter = await play(actualBefore, <bool>[false]);
      // Assert
      expect(actualBefore.isFinished, isFalse);
      expect(actualAfter.isFinished, isTrue);
      expect(actualAfter.livesLeft, 0);
      expect(actualAfter.correctCount, 1);
      expect(actualAfter.scoredAnswers, hasLength(4));
    });
    test('shortens the time every 5 right answers', () async {
      // Arrange
      final QuizRun inputRun = await buildLivesRun();
      // Act
      final QuizRun actualAfterFour = await play(
        inputRun,
        List<bool>.filled(4, true),
      );
      final QuizSubmission actualFifth = await answer(
        actualAfterFour,
        isRight: true,
      );
      // Assert
      expect(inputRun.currentTimeLimit, _start);
      expect(actualAfterFour.currentTimeLimit, _start);
      expect(
        actualFifth.run.currentTimeLimit,
        const Duration(milliseconds: 9500),
      );
      expect(actualFifth.answeredTimeLimit, _start);
    });
    test('stretches the schedule with the relaxed timer', () async {
      // Act
      final QuizRun actualRun = await buildLivesRun(
        timeLimit: const Duration(seconds: 15),
      );
      // Assert
      expect(actualRun.currentTimeLimit, const Duration(seconds: 15));
      expect(actualRun.timeSchedule!.floor, const Duration(seconds: 6));
    });
    test('has no schedule without a timer', () async {
      // Act
      final QuizRun actualRun = await buildLivesRun(timeLimit: null);
      // Assert
      expect(actualRun.timeSchedule, isNull);
      expect(actualRun.currentTimeLimit, isNull);
    });
  });

  group('A quiz without lives', () {
    test('has no lives to count', () async {
      // Act
      final QuizRun actualRun = await buildRun(tableKeys(5));
      // Assert
      expect(actualRun.livesLeft, isNull);
      expect(actualRun.isNonStop, isFalse);
      expect(actualRun.currentTimeLimit, actualRun.timeLimit);
    });
  });
}
