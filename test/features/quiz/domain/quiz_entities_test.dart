import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';

import '../helpers/quiz_fixtures.dart';

QuizAnswerEntity _answer({bool isCorrect = true}) {
  return QuizAnswerEntity(
    itemKey: 'mul:5x2',
    questionTypeId: QuestionTypeIds.typedAnswer,
    isCorrect: isCorrect,
    isTimedOut: false,
    isRetry: false,
    answerTime: const Duration(seconds: 2),
  );
}

QuizSessionEntity _session({int correctCount = 8}) {
  return QuizSessionEntity(
    id: 'session-1',
    profileId: 'p1',
    domainId: 'multiplication',
    mode: QuizMode.path,
    status: QuizSessionStatus.completed,
    startedAt: quizStart,
    duration: const Duration(minutes: 2),
    questionCount: 10,
    correctCount: correctCount,
    sourceKey: 'path:mul:5:boss',
    bossOutcome: BossOutcome.defeated,
  );
}

void main() {
  group('QuizRequest.fromSpec', () {
    test('copies every field of the spec', () {
      // Arrange
      final QuizSpec inputSpec = QuizSpec(
        domainId: 'multiplication',
        mode: QuizMode.path,
        itemKeys: tableKeys(5),
        questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
        selection: QuizSelection.shuffled,
        questionCount: 8,
        baseTimeLimit: const Duration(seconds: 8),
        sourceKey: 'path:mul:5:boss',
        followUpItemKeys: tableKeys(4),
        followUpQuestionCount: 6,
        isBossFight: true,
        totalTimeLimit: const Duration(minutes: 1),
        keepsTimer: true,
      );
      // Act
      final QuizRequest actualRequest = QuizRequest.fromSpec(
        profileId: 'p1',
        spec: inputSpec,
      );
      // Assert
      expect(actualRequest.profileId, 'p1');
      expect(actualRequest.domainId, inputSpec.domainId);
      expect(actualRequest.mode, inputSpec.mode);
      expect(actualRequest.itemKeys, inputSpec.itemKeys);
      expect(actualRequest.questionTypeIds, inputSpec.questionTypeIds);
      expect(actualRequest.selection, inputSpec.selection);
      expect(actualRequest.questionCount, 8);
      expect(actualRequest.baseTimeLimit, inputSpec.baseTimeLimit);
      expect(actualRequest.sourceKey, inputSpec.sourceKey);
      expect(actualRequest.followUpItemKeys, inputSpec.followUpItemKeys);
      expect(actualRequest.followUpQuestionCount, 6);
      expect(actualRequest.isBossFight, isTrue);
      expect(actualRequest.totalTimeLimit, inputSpec.totalTimeLimit);
      expect(actualRequest.keepsTimer, isTrue);
    });
  });

  group('QuizRun', () {
    test('equals a run built the same way', () async {
      // Arrange
      final QuizRun inputRun = await buildRun(tableKeys(5));
      final QuizRun expectedRun = await buildRun(tableKeys(5));
      // Act
      final bool actualIsEqual = inputRun == expectedRun;
      // Assert
      expect(actualIsEqual, isTrue);
      expect(inputRun.hashCode, expectedRun.hashCode);
    });

    test('differs from a run with other answers or questions', () async {
      // Arrange
      final QuizRun inputRun = await buildRun(tableKeys(5));
      // Act
      final bool actualIsEqualWithAnswer =
          inputRun == inputRun.copyWith(answers: <QuizAnswerEntity>[_answer()]);
      final bool actualIsEqualWithOtherTurn =
          inputRun ==
          inputRun.copyWith(
            queue: inputRun.queue.reversed.toList(),
          );
      // Assert
      expect(actualIsEqualWithAnswer, isFalse);
      expect(actualIsEqualWithOtherTurn, isFalse);
    });
  });

  group('QuizTurn', () {
    test('compares by question and second chance', () async {
      // Arrange
      final QuizRun inputRun = await buildRun(tableKeys(5));
      final QuizTurn inputTurn = inputRun.queue.first;
      final QuizTurn expectedTurn = QuizTurn(question: inputTurn.question);
      // Act
      final bool actualIsEqual = inputTurn == expectedTurn;
      final bool actualIsRetryEqual =
          inputTurn == QuizTurn(question: inputTurn.question, isRetry: true);
      // Assert
      expect(actualIsEqual, isTrue);
      expect(inputTurn.hashCode, expectedTurn.hashCode);
      expect(actualIsRetryEqual, isFalse);
    });
  });

  group('QuizSessionEntity', () {
    test('compares by value', () {
      // Arrange
      final QuizSessionEntity inputSession = _session();
      final QuizSessionEntity expectedSession = _session();
      // Act
      final bool actualIsEqual = inputSession == expectedSession;
      final bool actualIsOtherEqual = inputSession == _session(correctCount: 9);
      // Assert
      expect(actualIsEqual, isTrue);
      expect(inputSession.hashCode, expectedSession.hashCode);
      expect(actualIsOtherEqual, isFalse);
    });
  });

  group('QuizAnswerEntity', () {
    test('compares by value', () {
      // Arrange
      final QuizAnswerEntity inputAnswer = _answer();
      final QuizAnswerEntity expectedAnswer = _answer();
      // Act
      final bool actualIsEqual = inputAnswer == expectedAnswer;
      final bool actualIsOtherEqual = inputAnswer == _answer(isCorrect: false);
      // Assert
      expect(actualIsEqual, isTrue);
      expect(inputAnswer.hashCode, expectedAnswer.hashCode);
      expect(actualIsOtherEqual, isFalse);
    });
  });

  group('BossFight', () {
    test('compares by hit points and last damage', () {
      // Arrange
      const BossFight inputFight = BossFight(
        remainingHitPoints: 10,
        lastDamage: 2,
      );
      final BossFight expectedFight = BossFight(
        remainingHitPoints: int.parse('10'),
        lastDamage: 2,
      );
      // Act
      final bool actualIsEqual = inputFight == expectedFight;
      final bool actualIsOtherEqual =
          inputFight == const BossFight(remainingHitPoints: 10, lastDamage: 1);
      // Assert
      expect(actualIsEqual, isTrue);
      expect(inputFight.hashCode, expectedFight.hashCode);
      expect(actualIsOtherEqual, isFalse);
    });
  });
}
