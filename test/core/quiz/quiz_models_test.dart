import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';

Question _buildQuestion({List<Answer>? choices}) {
  return Question(
    itemKey: 'mul:7x8',
    questionTypeId: 'multipleChoice',
    prompt: const <PromptToken>[
      NumberToken(7),
      OperatorToken(MathOperator.multiply),
      NumberToken(8),
      EqualsToken(),
      BlankToken(),
    ],
    choices:
        choices ??
        const <Answer>[
          NumberAnswer(49),
          NumberAnswer(56),
          NumberAnswer(64),
          NumberAnswer(65),
        ],
    expectedAnswer: const NumberAnswer(56),
  );
}

void main() {
  group('Answer', () {
    test('compares by value', () {
      // Assert
      expect(const NumberAnswer(56), const NumberAnswer(56));
      expect(const NumberAnswer(56), isNot(const NumberAnswer(65)));
      expect(
        const BooleanAnswer(value: true),
        const BooleanAnswer(value: true),
      );
      expect(const NumberAnswer(1), isNot(const BooleanAnswer(value: true)));
    });
  });

  group('PromptToken', () {
    test('compares by kind and value', () {
      // Assert
      expect(const NumberToken(7), const NumberToken(7));
      expect(const NumberToken(7), isNot(const NumberToken(8)));
      expect(const EqualsToken(), const EqualsToken());
      expect(const BlankToken(), isNot(const EqualsToken()));
    });
  });

  group('Question', () {
    test('is equal to a question with the same content', () {
      // Act
      final Question actualQuestion = _buildQuestion();
      // Assert
      expect(actualQuestion, _buildQuestion());
      expect(actualQuestion.hashCode, _buildQuestion().hashCode);
    });
    test('differs when the choices are in another order', () {
      // Act
      final Question actualQuestion = _buildQuestion(
        choices: const <Answer>[
          NumberAnswer(56),
          NumberAnswer(49),
          NumberAnswer(64),
          NumberAnswer(65),
        ],
      );
      // Assert
      expect(actualQuestion, isNot(_buildQuestion()));
    });
    test('cannot be changed after creation', () {
      // Arrange
      final Question inputQuestion = _buildQuestion();
      // Act
      void actualChange() => inputQuestion.choices.add(const NumberAnswer(1));
      // Assert
      expect(actualChange, throwsUnsupportedError);
    });
    test('reads like the prompt it shows', () {
      // Act
      final String actualText = _buildQuestion().toString();
      // Assert
      expect(actualText, 'Question(multipleChoice, 7 multiply 8 = ?)');
    });
  });
}
