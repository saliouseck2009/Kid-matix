import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels_spoken_text.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

import '../helpers/quiz_fixtures.dart';

const List<PromptToken> _fiveTimesSeven = <PromptToken>[
  NumberToken(5),
  OperatorToken(MathOperator.multiply),
  NumberToken(7),
  EqualsToken(),
  BlankToken(),
];

Question _question(
  String typeId, {
  List<PromptToken> prompt = _fiveTimesSeven,
  List<Answer> choices = const <Answer>[],
  List<QuestionPair> pairs = const <QuestionPair>[],
}) {
  return Question(
    itemKey: 'mul:5x7',
    unitKey: 'mul:5',
    questionTypeId: typeId,
    prompt: prompt,
    expectedAnswer: const NumberAnswer(35),
    choices: choices,
    pairs: pairs,
  );
}

Future<QuizLabelsSpokenText> _textIn(String languageCode) async {
  final AppLocalizations l10n = await AppLocalizations.delegate.load(
    Locale(languageCode),
  );
  return QuizLabelsSpokenText(
    labels: QuizLabels(domains: buildDomainRegistry(), l10n: l10n),
    domainId: MultiplicationDomain.domainId,
  );
}

void main() {
  group('QuizLabelsSpokenText.ofQuestion in French', () {
    late QuizLabelsSpokenText text;

    setUp(() async => text = await _textIn('fr'));

    test('reads an operation to complete as a sentence', () {
      // Act
      final String actualText = text.ofQuestion(
        _question(QuestionTypeIds.typedAnswer),
      );
      // Assert
      expect(actualText, '5 fois 7 égale combien');
    });
    test('reads a missing number in place', () {
      // Arrange
      final Question inputQuestion = _question(
        QuestionTypeIds.missingNumber,
        prompt: const <PromptToken>[
          NumberToken(7),
          OperatorToken(MathOperator.multiply),
          BlankToken(),
          EqualsToken(),
          NumberToken(56),
        ],
      );
      // Act
      final String actualText = text.ofQuestion(inputQuestion);
      // Assert
      expect(actualText, '7 fois combien égale 56');
    });
    test('reads a statement to judge, then asks "Vrai ou faux ?"', () {
      // Arrange
      final Question inputQuestion = _question(
        QuestionTypeIds.trueFalse,
        prompt: const <PromptToken>[
          NumberToken(6),
          OperatorToken(MathOperator.multiply),
          NumberToken(7),
          EqualsToken(),
          NumberToken(48),
        ],
      );
      // Act
      final String actualText = text.ofQuestion(inputQuestion);
      // Assert
      expect(actualText, '6 fois 7 égale 48. Vrai ou faux ?');
    });
    test('reads the question that asks for the operation', () {
      // Arrange
      final Question inputQuestion = _question(
        QuestionTypeIds.findOperation,
        prompt: const <PromptToken>[
          BlankToken(),
          EqualsToken(),
          NumberToken(24),
        ],
      );
      // Act
      final String actualText = text.ofQuestion(inputQuestion);
      // Assert
      expect(actualText, 'Quelle multiplication donne 24 ?');
    });
    test('reads the instruction of the pairs board', () {
      // Act
      final String actualText = text.ofQuestion(
        _question(QuestionTypeIds.matchPairs),
      );
      // Assert
      expect(actualText, 'Relie chaque opération à son résultat');
    });
    test('reads a type it does not know like an operation', () {
      // Arrange: a type added later, with the tokens of the prompt only.
      final Question inputQuestion = _question('someNewType');
      // Act
      final String actualText = text.ofQuestion(inputQuestion);
      // Assert
      expect(actualText, '5 fois 7 égale combien');
    });
  });

  group('QuizLabelsSpokenText.ofQuestion in other languages', () {
    test('speaks English', () async {
      // Arrange
      final QuizLabelsSpokenText text = await _textIn('en');
      // Act
      final String actualText = text.ofQuestion(
        _question(QuestionTypeIds.trueFalse),
      );
      // Assert
      expect(actualText, '5 times 7 equals what. True or false?');
    });
    test('speaks Spanish', () async {
      // Arrange
      final QuizLabelsSpokenText text = await _textIn('es');
      // Act
      final String actualText = text.ofQuestion(
        _question(QuestionTypeIds.multipleChoice),
      );
      // Assert
      expect(actualText, '5 por 7 es igual a cuánto');
    });
  });

  group('QuizLabelsSpokenText.ofInstruction', () {
    late QuizLabelsSpokenText text;

    setUp(() async => text = await _textIn('fr'));

    test('reads what to do under the answers to pick', () {
      // Arrange
      final Question inputQuestion = _question(
        QuestionTypeIds.multipleChoice,
        choices: const <Answer>[NumberAnswer(35), NumberAnswer(30)],
      );
      // Act
      final String? actualText = text.ofInstruction(inputQuestion);
      // Assert
      expect(actualText, 'Touche la bonne réponse');
    });
    test('reads the instruction of a true or false question', () {
      // Act
      final String? actualText = text.ofInstruction(
        _question(QuestionTypeIds.trueFalse),
      );
      // Assert
      expect(actualText, 'Ce calcul est-il juste ?');
    });
    test('has none where the answer is written on the keypad', () {
      // Act
      final String? actualText = text.ofInstruction(
        _question(QuestionTypeIds.typedAnswer),
      );
      // Assert
      expect(actualText, isNull);
    });
  });
}
