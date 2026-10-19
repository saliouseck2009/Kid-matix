import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/comparison.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/app_question_types.dart';
import 'package:kid_matix/core/quiz/question_types/number_question_types.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

QuestionType _typeOf(String id) {
  return numberQuestionTypes.singleWhere((QuestionType type) => type.id == id);
}

void main() {
  group('question types of the numbers', () {
    test('are registered after version 1.1, with distinct identifiers', () {
      // Act
      final List<String> actualIds = appQuestionTypes
          .map((QuestionType type) => type.id)
          .toList();
      // Assert
      expect(
        actualIds.sublist(actualIds.length - 8, actualIds.length - 4),
        <String>[
          QuestionTypeIds.countObjects,
          QuestionTypeIds.tensAndOnes,
          QuestionTypeIds.compare,
          QuestionTypeIds.numberLine,
        ],
      );
      expect(actualIds.toSet(), hasLength(actualIds.length));
    });
    test('pick the numbers, decide the comparison', () {
      // Assert
      expect(
        _typeOf(QuestionTypeIds.countObjects).answerNature,
        AnswerNature.recognized,
      );
      expect(
        _typeOf(QuestionTypeIds.tensAndOnes).answerNature,
        AnswerNature.recognized,
      );
      expect(
        _typeOf(QuestionTypeIds.numberLine).answerNature,
        AnswerNature.recognized,
      );
      expect(
        _typeOf(QuestionTypeIds.compare).answerNature,
        AnswerNature.produced,
      );
      for (final QuestionType type in numberQuestionTypes) {
        final int expectedFactor = type.id == QuestionTypeIds.countObjects
            ? 2
            : 1;
        expect(type.timeFactor, expectedFactor, reason: type.id);
      }
    });
    test('judge a comparison by its sign', () {
      // Arrange
      final Question inputQuestion = Question(
        itemKey: 'num:compare:34:43',
        unitKey: 'num:compare',
        questionTypeId: QuestionTypeIds.compare,
        prompt: const <PromptToken>[
          NumberToken(34),
          BlankToken(),
          NumberToken(43),
        ],
        choices: ComparisonAnswer.all,
        expectedAnswer: const ComparisonAnswer(Comparison.less),
      );
      final QuestionType inputType = _typeOf(QuestionTypeIds.compare);
      // Act & Assert
      expect(
        inputType.isCorrect(
          question: inputQuestion,
          answer: const ComparisonAnswer(Comparison.less),
        ),
        isTrue,
      );
      expect(
        inputType.isCorrect(
          question: inputQuestion,
          answer: const ComparisonAnswer(Comparison.greater),
        ),
        isFalse,
      );
    });
    test('judge a drawn number by its value', () {
      // Arrange
      final Question inputQuestion = Question(
        itemKey: 'num:count:7',
        unitKey: 'num:count10',
        questionTypeId: QuestionTypeIds.countObjects,
        prompt: const <PromptToken>[BlankToken()],
        picture: const ObjectsPicture(count: 7),
        choices: const <Answer>[NumberAnswer(7), NumberAnswer(6)],
        expectedAnswer: const NumberAnswer(7),
      );
      // Act & Assert
      for (final String id in <String>[
        QuestionTypeIds.countObjects,
        QuestionTypeIds.tensAndOnes,
        QuestionTypeIds.numberLine,
      ]) {
        expect(
          _typeOf(id).isCorrect(
            question: inputQuestion,
            answer: const NumberAnswer(7),
          ),
          isTrue,
        );
        expect(
          _typeOf(id).isCorrect(
            question: inputQuestion,
            answer: const NumberAnswer(6),
          ),
          isFalse,
        );
      }
    });
  });

  group('Comparison', () {
    test('tells how a first number compares with a second', () {
      // Assert
      expect(Comparison.of(3, 8), Comparison.less);
      expect(Comparison.of(15, 15), Comparison.equal);
      expect(Comparison.of(58, 49), Comparison.greater);
    });
  });

  group('pictures and questions', () {
    test('compare by value', () {
      // Assert
      expect(
        NumberLinePicture(values: const <int>[1, 2], blankIndex: 1),
        NumberLinePicture(values: const <int>[1, 2], blankIndex: 1),
      );
      expect(
        NumberLinePicture(values: const <int>[1, 2], blankIndex: 1),
        isNot(NumberLinePicture(values: const <int>[1, 2], blankIndex: 0)),
      );
      expect(const TenBundlesPicture(tens: 3, ones: 4).value, 34);
      final Question withPicture = Question(
        itemKey: 'num:count:7',
        unitKey: 'num:count10',
        questionTypeId: QuestionTypeIds.typedAnswer,
        prompt: const <PromptToken>[BlankToken()],
        picture: const ObjectsPicture(count: 7),
        expectedAnswer: const NumberAnswer(7),
      );
      final Question otherPicture = Question(
        itemKey: 'num:count:7',
        unitKey: 'num:count10',
        questionTypeId: QuestionTypeIds.typedAnswer,
        prompt: const <PromptToken>[BlankToken()],
        picture: const ObjectsPicture(count: 8),
        expectedAnswer: const NumberAnswer(7),
      );
      expect(withPicture, isNot(otherPicture));
      expect(withPicture.hashCode, isNot(otherPicture.hashCode));
    });
  });

  group('PromptReading of the signs of version 2.0', () {
    final AppLocalizationsFr l10n = AppLocalizationsFr();

    test('shows and says plus, smaller and greater', () {
      // Arrange
      const List<PromptToken> inputSum = <PromptToken>[
        NumberToken(30),
        OperatorToken(MathOperator.add),
        NumberToken(4),
        EqualsToken(),
        NumberToken(34),
      ];
      const List<PromptToken> inputLess = <PromptToken>[
        NumberToken(34),
        OperatorToken(MathOperator.lessThan),
        NumberToken(43),
      ];
      const List<PromptToken> inputGreater = <PromptToken>[
        NumberToken(58),
        OperatorToken(MathOperator.greaterThan),
        NumberToken(49),
      ];
      // Assert
      expect(inputSum.toDisplayText(), '30 + 4 = 34');
      expect(inputSum.toSpokenText(l10n), '30 plus 4 égale 34');
      expect(inputLess.toDisplayText(), '34 < 43');
      expect(inputLess.toSpokenText(l10n), '34 est plus petit que 43');
      expect(inputGreater.toDisplayText(), '58 > 49');
      expect(inputGreater.toSpokenText(l10n), '58 est plus grand que 49');
    });
  });
}
