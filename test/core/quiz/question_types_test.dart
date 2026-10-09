import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/question_types/version_one_question_types.dart';

Question _buildQuestion(String questionTypeId, Answer expectedAnswer) {
  return Question(
    itemKey: 'mul:7x8',
    questionTypeId: questionTypeId,
    prompt: const <PromptToken>[
      NumberToken(7),
      OperatorToken(MathOperator.multiply),
      NumberToken(8),
      EqualsToken(),
      BlankToken(),
    ],
    expectedAnswer: expectedAnswer,
  );
}

QuestionType _findType(String id) {
  return versionOneQuestionTypes.singleWhere(
    (QuestionType type) => type.id == id,
  );
}

void main() {
  group('version 1.0 question types', () {
    test('have distinct identifiers', () {
      // Act
      final Set<String> actualIds = versionOneQuestionTypes
          .map((QuestionType type) => type.id)
          .toSet();
      // Assert
      expect(actualIds, <String>{
        QuestionTypeIds.multipleChoice,
        QuestionTypeIds.typedAnswer,
        QuestionTypeIds.missingNumber,
        QuestionTypeIds.trueFalse,
      });
    });
    test('pick or write the answer as the mastery engine expects', () {
      // Assert
      expect(
        _findType(QuestionTypeIds.multipleChoice).answerNature,
        AnswerNature.recognized,
      );
      expect(
        _findType(QuestionTypeIds.trueFalse).answerNature,
        AnswerNature.recognized,
      );
      expect(
        _findType(QuestionTypeIds.typedAnswer).answerNature,
        AnswerNature.produced,
      );
      expect(
        _findType(QuestionTypeIds.missingNumber).answerNature,
        AnswerNature.produced,
      );
    });
    for (final String inputTypeId in <String>[
      QuestionTypeIds.multipleChoice,
      QuestionTypeIds.typedAnswer,
      QuestionTypeIds.missingNumber,
    ]) {
      test('$inputTypeId accepts only the expected number', () {
        // Arrange
        final QuestionType inputType = _findType(inputTypeId);
        final Question inputQuestion = _buildQuestion(
          inputTypeId,
          const NumberAnswer(56),
        );
        // Act
        final bool actualRight = inputType.isCorrect(
          question: inputQuestion,
          answer: const NumberAnswer(56),
        );
        final bool actualWrong = inputType.isCorrect(
          question: inputQuestion,
          answer: const NumberAnswer(65),
        );
        // Assert
        expect(actualRight, isTrue);
        expect(actualWrong, isFalse);
      });
    }
    test('trueFalse accepts only the right verdict', () {
      // Arrange
      final QuestionType inputType = _findType(QuestionTypeIds.trueFalse);
      final Question inputQuestion = _buildQuestion(
        QuestionTypeIds.trueFalse,
        const BooleanAnswer(value: false),
      );
      // Act
      final bool actualRight = inputType.isCorrect(
        question: inputQuestion,
        answer: const BooleanAnswer(value: false),
      );
      final bool actualWrong = inputType.isCorrect(
        question: inputQuestion,
        answer: const BooleanAnswer(value: true),
      );
      // Assert
      expect(actualRight, isTrue);
      expect(actualWrong, isFalse);
    });
  });
}
