import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_submission.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_use_case.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';
import '../helpers/quiz_fixtures.dart';

const Duration _normal = Duration(seconds: 4);
const Duration _lightning = Duration(seconds: 2);

BuildQuizParams _bossParams({List<String>? followUp}) {
  return BuildQuizParams(
    profileId: 'profile-1',
    domainId: 'multiplication',
    mode: QuizMode.path,
    itemKeys: tableKeys(5),
    questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
    selection: QuizSelection.shuffled,
    followUpItemKeys: followUp ?? tableKeys(5),
    followUpQuestionCount: 10,
    isBossFight: true,
    timeLimit: const Duration(seconds: 8),
  );
}

void main() {
  late SubmitAnswerUseCase submit;

  setUp(() => submit = buildSubmitAnswerUseCase());

  Future<QuizRun> buildFight() async {
    return (await buildQuizUseCase()(params: _bossParams())).requireData;
  }

  Future<QuizSubmission> answer(
    QuizRun run, {
    bool isRight = true,
    Duration time = _normal,
  }) async {
    final Answer expected = run.currentTurn!.question.expectedAnswer;
    return (await submit(
      params: SubmitAnswerParams(
        run: run,
        answer: isRight ? expected : const NumberAnswer(-1),
        answerTime: time,
      ),
    )).requireData;
  }

  group('BossFight', () {
    test('starts with 12 hit points and 20 questions at most', () async {
      // Act
      final QuizRun actualRun = await buildFight();
      // Assert
      expect(actualRun.boss, const BossFight());
      expect(actualRun.boss!.remainingHitPoints, 12);
      expect(actualRun.queue, hasLength(20));
      expect(
        actualRun.queue
            .take(10)
            .map((QuizTurn turn) => turn.question.itemKey)
            .toSet(),
        tableKeys(5).toSet(),
      );
    });
    test('loses 1 hit point on a right answer, 2 on a lightning one', () async {
      // Arrange
      final QuizRun inputRun = await buildFight();
      // Act
      final QuizSubmission actualHit = await answer(inputRun);
      final QuizSubmission actualCritical = await answer(
        actualHit.run,
        time: _lightning,
      );
      // Assert
      expect(actualHit.run.boss!.remainingHitPoints, 11);
      expect(actualHit.run.boss!.isLastHitCritical, isFalse);
      expect(actualCritical.run.boss!.remainingHitPoints, 9);
      expect(actualCritical.run.boss!.isLastHitCritical, isTrue);
    });
    test('costs the player nothing on a mistake', () async {
      // Arrange
      final QuizRun inputRun = await buildFight();
      // Act
      final QuizSubmission actualMiss = await answer(inputRun, isRight: false);
      // Assert
      expect(actualMiss.run.boss!.remainingHitPoints, 12);
      expect(actualMiss.run.boss!.lastDamage, 0);
      expect(actualMiss.run.queue[2].isRetry, isTrue);
    });
    test('is won with 60 % of right answers and no critical hit', () async {
      // Arrange
      QuizRun run = await buildFight();
      // Act
      for (int index = 0; index < 20 && !run.isFinished; index++) {
        run = (await answer(run, isRight: index >= 8)).run;
      }
      // Assert
      expect(run.answers, hasLength(20));
      expect(run.correctCount, 12);
      expect(run.bossOutcome, BossOutcome.defeated);
    });
    test('ends as soon as the boss falls', () async {
      // Arrange
      QuizRun run = await buildFight();
      // Act
      for (int index = 0; index < 6; index++) {
        run = (await answer(run, time: _lightning)).run;
      }
      // Assert
      expect(run.isFinished, isTrue);
      expect(run.answers, hasLength(6));
      expect(run.bossOutcome, BossOutcome.defeated);
    });
    test('flees after the 20th question', () async {
      // Arrange
      QuizRun run = await buildFight();
      // Act
      for (int index = 0; index < 20 && !run.isFinished; index++) {
        run = (await answer(run, isRight: index.isEven)).run;
      }
      // Assert
      expect(run.answers, hasLength(20));
      expect(run.isFinished, isTrue);
      expect(run.boss!.remainingHitPoints, 2);
      expect(run.bossOutcome, BossOutcome.fled);
    });
    test('scores every answer, second chances included', () async {
      // Arrange
      QuizRun run = await buildFight();
      for (int index = 0; index < 20 && !run.isFinished; index++) {
        run = (await answer(run, isRight: index != 0)).run;
      }
      // Act
      final QuizSessionEntity actualSession = QuizSessionEntity.fromRun(
        run: run,
        status: QuizSessionStatus.completed,
        endedAt: quizStart,
      );
      // Assert
      expect(actualSession.questionCount, run.answers.length);
      expect(actualSession.correctCount, run.answers.length - 1);
      expect(actualSession.bossOutcome, BossOutcome.defeated);
    });
    test(
      'draws each follow-up item once after the facts of the table',
      () async {
        // Act
        final QuizRun actualRun =
            (await buildQuizUseCase(
                  mastery: FakeMasteryService(),
                )(
                  params: _bossParams(followUp: <String>['mul:2x3', 'mul:2x3']),
                ))
                .requireData;
        // Assert
        expect(actualRun.queue, hasLength(11));
        expect(actualRun.queue.last.question.itemKey, 'mul:2x3');
      },
    );
    test('is not a boss fight for another quiz', () async {
      // Act
      final QuizRun actualRun = await buildRun(tableKeys(5));
      // Assert
      expect(actualRun.boss, isNull);
      expect(actualRun.bossOutcome, isNull);
    });
  });
}
