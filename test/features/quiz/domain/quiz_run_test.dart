import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';

import '../helpers/quiz_fixtures.dart';

QuizAnswerEntity _answer(String itemKey, {required bool isCorrect}) {
  return QuizAnswerEntity(
    itemKey: itemKey,
    questionTypeId: 'typedAnswer',
    isCorrect: isCorrect,
    isTimedOut: false,
    isRetry: false,
    answerTime: const Duration(seconds: 2),
  );
}

void main() {
  group('QuizRun help card', () {
    test('needs help from the second mistake on the same fact', () async {
      // Arrange
      final QuizRun inputRun = await buildRun(tableKeys(5));
      // Act
      final QuizRun actualOnce = inputRun.copyWith(
        answers: <QuizAnswerEntity>[
          _answer('mul:5x7', isCorrect: false),
          _answer('mul:5x8', isCorrect: false),
          _answer('mul:5x7', isCorrect: true),
        ],
      );
      final QuizRun actualTwice = actualOnce.copyWith(
        answers: <QuizAnswerEntity>[
          ...actualOnce.answers,
          _answer('mul:5x7', isCorrect: false),
        ],
      );
      // Assert
      expect(actualOnce.mistakeCountOf('mul:5x7'), 1);
      expect(actualOnce.needsHelp('mul:5x7'), isFalse);
      expect(actualTwice.mistakeCountOf('mul:5x7'), 2);
      expect(actualTwice.needsHelp('mul:5x7'), isTrue);
      expect(actualTwice.needsHelp('mul:5x8'), isFalse);
    });
  });
}
