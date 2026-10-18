import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/number/domain/services/numbers_domain.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

import '../helpers/quiz_fixtures.dart';

const List<PromptToken> _fiveTimesSeven = <PromptToken>[
  NumberToken(5),
  OperatorToken(MathOperator.multiply),
  NumberToken(7),
  EqualsToken(),
  BlankToken(),
];

const List<PromptToken> _thirtyFourAndFortyThree = <PromptToken>[
  NumberToken(34),
  BlankToken(),
  NumberToken(43),
];

Question _question(
  String typeId, {
  List<PromptToken> prompt = _fiveTimesSeven,
  List<Answer> choices = const <Answer>[],
  List<QuestionPair> pairs = const <QuestionPair>[],
  MathPicture? picture,
}) {
  return Question(
    itemKey: 'mul:5x7',
    unitKey: 'mul:5',
    questionTypeId: typeId,
    prompt: prompt,
    expectedAnswer: const NumberAnswer(35),
    choices: choices,
    pairs: pairs,
    picture: picture,
  );
}

Future<QuizLabels> _labelsIn(String languageCode) async {
  return QuizLabels(
    domains: buildDomainRegistry(),
    l10n: await AppLocalizations.delegate.load(Locale(languageCode)),
  );
}

void main() {
  const String multiplication = MultiplicationDomain.domainId;
  const String numbers = NumbersDomain.domainId;

  group('QuizLabels.speakQuestion in French', () {
    late QuizLabels labels;

    setUp(() async => labels = await _labelsIn('fr'));

    test('reads an operation to complete as a sentence', () {
      // Act
      final String actualText = labels.speakQuestion(
        _question(QuestionTypeIds.typedAnswer),
        multiplication,
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
      final String actualText = labels.speakQuestion(
        inputQuestion,
        multiplication,
      );
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
      final String actualText = labels.speakQuestion(
        inputQuestion,
        multiplication,
      );
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
      final String actualText = labels.speakQuestion(
        inputQuestion,
        multiplication,
      );
      // Assert
      expect(actualText, 'Quelle multiplication donne 24 ?');
    });
    test('reads the instruction of the pairs board', () {
      // Act
      final String actualText = labels.speakQuestion(
        _question(QuestionTypeIds.matchPairs),
        multiplication,
      );
      // Assert
      expect(actualText, 'Relie chaque opération à son résultat');
    });
    test('reads a type it does not know like an operation', () {
      // Arrange: a type added later, with the tokens of the prompt only.
      final Question inputQuestion = _question('someNewType');
      // Act
      final String actualText = labels.speakQuestion(
        inputQuestion,
        multiplication,
      );
      // Assert
      expect(actualText, '5 fois 7 égale combien');
    });
  });

  group('QuizLabels.speakQuestion for the formats of the numbers', () {
    late QuizLabels labels;

    setUp(() async => labels = await _labelsIn('fr'));

    test('asks how many objects are drawn, with an empty prompt', () {
      // Arrange
      final Question inputQuestion = _question(
        QuestionTypeIds.countObjects,
        prompt: const <PromptToken>[],
        picture: const ObjectsPicture(count: 7),
      );
      // Act
      final String actualText = labels.speakQuestion(inputQuestion, numbers);
      // Assert
      expect(actualText, 'Combien de mangues ?');
    });
    test('counts the bundles of ten and the loose sticks', () {
      // Arrange
      final Question inputQuestion = _question(
        QuestionTypeIds.tensAndOnes,
        prompt: const <PromptToken>[],
        picture: const TenBundlesPicture(tens: 3, ones: 4),
      );
      // Act
      final String actualText = labels.speakQuestion(inputQuestion, numbers);
      // Assert
      expect(
        actualText,
        '3 paquets de dix et 4 bâtonnets : quel nombre ?',
      );
    });
    test('reads the numbers of a line and hides the missing one', () {
      // Arrange
      final Question inputQuestion = _question(
        QuestionTypeIds.numberLine,
        prompt: const <PromptToken>[],
        picture: NumberLinePicture(
          values: const <int>[2, 4, 6, 8, 10],
          blankIndex: 3,
        ),
      );
      // Act
      final String actualText = labels.speakQuestion(inputQuestion, numbers);
      // Assert
      expect(
        actualText,
        'Droite des nombres : 2, 4, 6, nombre caché, 10. '
        'Quel nombre manque ?',
      );
    });
    test('compares two numbers instead of reading "34 combien 43"', () {
      // Arrange
      final Question inputQuestion = _question(
        QuestionTypeIds.compare,
        prompt: _thirtyFourAndFortyThree,
        choices: ComparisonAnswer.all,
      );
      // Act
      final String actualText = labels.speakQuestion(inputQuestion, numbers);
      // Assert
      expect(
        actualText,
        '34 est-il plus petit, égal ou plus grand que 43 ?',
      );
    });
    test('reads a number written as tens and ones with its words', () {
      // Arrange
      final Question inputQuestion = _question(
        QuestionTypeIds.typedAnswer,
        prompt: const <PromptToken>[
          NumberToken(30),
          OperatorToken(MathOperator.add),
          NumberToken(4),
          EqualsToken(),
          BlankToken(),
        ],
      );
      // Act
      final String actualText = labels.speakQuestion(inputQuestion, numbers);
      // Assert
      expect(actualText, '30 plus 4 égale combien');
    });
    test('reads the sign between two numbers as words', () {
      // Arrange
      final Question inputQuestion = _question(
        QuestionTypeIds.trueFalse,
        prompt: const <PromptToken>[
          NumberToken(34),
          OperatorToken(MathOperator.lessThan),
          NumberToken(43),
        ],
      );
      // Act
      final String actualText = labels.speakQuestion(inputQuestion, numbers);
      // Assert
      expect(actualText, '34 est plus petit que 43. Vrai ou faux ?');
    });
  });

  group('QuizLabels.speakQuestion in other languages', () {
    test('speaks English', () async {
      // Arrange
      final QuizLabels labels = await _labelsIn('en');
      // Act
      final String actualText = labels.speakQuestion(
        _question(QuestionTypeIds.trueFalse),
        multiplication,
      );
      // Assert
      expect(actualText, '5 times 7 equals what. True or false?');
    });
    test('speaks Spanish', () async {
      // Arrange
      final QuizLabels labels = await _labelsIn('es');
      // Act
      final String actualText = labels.speakQuestion(
        _question(QuestionTypeIds.multipleChoice),
        multiplication,
      );
      // Assert
      expect(actualText, '5 por 7 es igual a cuánto');
    });
    test('speaks a format of the numbers in English', () async {
      // Arrange
      final QuizLabels labels = await _labelsIn('en');
      final Question inputQuestion = _question(
        QuestionTypeIds.compare,
        prompt: _thirtyFourAndFortyThree,
        choices: ComparisonAnswer.all,
      );
      // Act
      final String actualText = labels.speakQuestion(inputQuestion, numbers);
      // Assert
      expect(actualText, 'Is 34 less than, equal to or greater than 43?');
    });
  });

  group('QuizLabels.describeHint', () {
    late QuizLabels labels;

    setUp(() async => labels = await _labelsIn('fr'));

    test('says what to do under the answers to pick', () {
      // Arrange
      final Question inputQuestion = _question(
        QuestionTypeIds.multipleChoice,
        choices: const <Answer>[NumberAnswer(35), NumberAnswer(30)],
      );
      // Act
      final String? actualText = labels.describeHint(inputQuestion);
      // Assert
      expect(actualText, 'Touche la bonne réponse');
    });
    test('says what to do for a true or false question', () {
      // Act
      final String? actualText = labels.describeHint(
        _question(QuestionTypeIds.trueFalse),
      );
      // Assert
      expect(actualText, 'Ce calcul est-il juste ?');
    });
    test('says what to do for the operation to find', () {
      // Act
      final String? actualText = labels.describeHint(
        _question(
          QuestionTypeIds.findOperation,
          choices: const <Answer>[NumberAnswer(1)],
        ),
      );
      // Assert
      expect(actualText, 'Touche la bonne opération');
    });
    test('has the right sign to touch for a comparison', () {
      // Act
      final String? actualText = labels.describeHint(
        _question(
          QuestionTypeIds.compare,
          prompt: _thirtyFourAndFortyThree,
          choices: ComparisonAnswer.all,
        ),
      );
      // Assert
      expect(actualText, 'Touche le bon signe');
    });
    test('has the answer to pick for the drawn formats', () {
      for (final (String typeId, MathPicture picture)
          in <(String, MathPicture)>[
            (QuestionTypeIds.countObjects, const ObjectsPicture(count: 7)),
            (
              QuestionTypeIds.tensAndOnes,
              const TenBundlesPicture(tens: 3, ones: 4),
            ),
            (
              QuestionTypeIds.numberLine,
              NumberLinePicture(values: const <int>[2, 4, 6], blankIndex: 1),
            ),
          ]) {
        // Arrange
        final Question inputQuestion = _question(
          typeId,
          prompt: const <PromptToken>[],
          picture: picture,
          choices: const <Answer>[NumberAnswer(7), NumberAnswer(8)],
        );
        // Act
        final String? actualText = labels.describeHint(inputQuestion);
        // Assert
        expect(actualText, 'Touche la bonne réponse', reason: typeId);
      }
    });
    test('has none where the answer is written on the keypad', () {
      // Act
      final String? actualText = labels.describeHint(
        _question(QuestionTypeIds.typedAnswer),
      );
      // Assert
      expect(actualText, isNull);
    });
    test('has none on the pairs board, which has its own hints', () {
      // Act
      final String? actualText = labels.describeHint(
        _question(QuestionTypeIds.matchPairs),
      );
      // Assert
      expect(actualText, isNull);
    });
  });
}
