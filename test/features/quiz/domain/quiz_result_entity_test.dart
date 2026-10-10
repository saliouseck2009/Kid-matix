import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';

import '../helpers/quiz_fixtures.dart';

QuizAnswerEntity _answer(
  String itemKey, {
  bool isCorrect = true,
  bool isTimedOut = false,
  bool isRetry = false,
  int ms = 2000,
}) {
  return QuizAnswerEntity(
    itemKey: itemKey,
    questionTypeId: 'typedAnswer',
    isCorrect: isCorrect,
    isTimedOut: isTimedOut,
    isRetry: isRetry,
    answerTime: Duration(milliseconds: ms),
  );
}

QuizResultEntity _result(List<QuizAnswerEntity> answers) {
  return QuizResultEntity(
    session: QuizSessionEntity(
      id: 's1',
      profileId: 'p1',
      domainId: 'multiplication',
      mode: QuizMode.freeTraining,
      status: QuizSessionStatus.completed,
      startedAt: quizStart,
      duration: const Duration(minutes: 1),
      questionCount: 3,
      correctCount: 1,
    ),
    answers: answers,
  );
}

void main() {
  group('QuizResultEntity', () {
    test('averages the scored answers given in time', () {
      // Arrange
      final QuizResultEntity inputResult = _result(<QuizAnswerEntity>[
        _answer('mul:5x1', ms: 2000),
        _answer('mul:5x2', ms: 3000),
        _answer('mul:5x3', isCorrect: false, isTimedOut: true, ms: 10000),
        _answer('mul:5x3', isRetry: true, ms: 9000),
      ]);
      // Act
      final Duration? actualAverage = inputResult.averageAnswerTime;
      // Assert
      expect(actualAverage, const Duration(milliseconds: 2500));
    });
    test('has no average when every answer timed out', () {
      // Arrange
      final QuizResultEntity inputResult = _result(<QuizAnswerEntity>[
        _answer('mul:5x1', isCorrect: false, isTimedOut: true),
      ]);
      // Assert
      expect(inputResult.averageAnswerTime, isNull);
    });
    test('lists each missed fact once, in order', () {
      // Arrange
      final QuizResultEntity inputResult = _result(<QuizAnswerEntity>[
        _answer('mul:5x8', isCorrect: false),
        _answer('mul:5x1'),
        _answer('mul:5x3', isCorrect: false),
        _answer('mul:5x8', isCorrect: false, isRetry: true),
      ]);
      // Assert
      expect(inputResult.missedItemKeys, <String>['mul:5x8', 'mul:5x3']);
      expect(inputResult.askedItemKeys, <String>[
        'mul:5x8',
        'mul:5x1',
        'mul:5x3',
      ]);
    });
  });
}
