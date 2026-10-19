import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/addition/domain/services/addition_domain.dart';
import 'package:kid_matix/features/division/domain/services/division_domain.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/l10n/app_localizations_en.dart';
import 'package:kid_matix/l10n/app_localizations_es.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

import '../helpers/quiz_fixtures.dart';

void main() {
  final DivisionDomain domain = DivisionDomain();
  final QuizLabels labels = QuizLabels(
    domains: buildDomainRegistry(),
    l10n: AppLocalizationsFr(),
  );

  Question questionOf(String typeId) {
    return domain.buildQuestion(
      item: domain.findItem('div:56/7')!,
      questionTypeId: typeId,
      random: DartRandomSource(seed: 3),
    );
  }

  group('texts of the division quiz', () {
    test('reminds 7 × 8 = 56 after a mistake on 56 ÷ 7', () {
      // Assert
      expect(labels.describeMirror('div:56/7', 'division'), '7 × 8 = 56');
      expect(labels.describeItem('div:56/7', 'division'), '56 ÷ 7 = 8');
    });
    test('names the unit above a question and in the boss title', () {
      // Act
      final Question inputQuestion = questionOf(QuestionTypeIds.typedAnswer);
      // Assert
      expect(
        labels.describeQuestion(inputQuestion, 'division'),
        'Diviser par 7',
      );
      expect(
        labels.describeBoss(inputQuestion, 'division'),
        'Boss · Diviser par 7',
      );
    });
    test('reads the division of every format aloud', () {
      // Assert
      expect(
        labels.speakQuestion(
          questionOf(QuestionTypeIds.multipleChoice),
          'division',
        ),
        '56 divisé par 7 égale combien',
      );
      expect(
        labels.speakQuestion(
          questionOf(QuestionTypeIds.typedAnswer),
          'division',
        ),
        '56 divisé par 7 égale combien',
      );
      final Question inputMissing = questionOf(QuestionTypeIds.missingNumber);
      expect(
        labels.speakQuestion(inputMissing, 'division'),
        anyOf('56 divisé par combien égale 8', 'combien divisé par 7 égale 8'),
      );
      final Question inputStatement = domain.buildQuestion(
        item: domain.findItem('div:56/7')!,
        questionTypeId: QuestionTypeIds.trueFalse,
        random: DartRandomSource(seed: 3),
      );
      expect(
        labels.speakQuestion(inputStatement, 'division'),
        allOf(startsWith('56 divisé par 7 égale '), contains('Vrai ou faux')),
      );
    });
    test('says "divided by" in English and "dividido entre" in Spanish', () {
      // Arrange
      final Question inputQuestion = questionOf(QuestionTypeIds.typedAnswer);
      // Assert
      expect(
        QuizLabels(
          domains: buildDomainRegistry(),
          l10n: AppLocalizationsEn(),
        ).speakQuestion(inputQuestion, 'division'),
        '56 divided by 7 equals what',
      );
      expect(
        QuizLabels(
          domains: buildDomainRegistry(),
          l10n: AppLocalizationsEs(),
        ).speakQuestion(inputQuestion, 'division'),
        '56 dividido entre 7 es igual a cuánto',
      );
    });
    test('gives the hint of the format', () {
      // Assert
      expect(
        labels.describeHint(questionOf(QuestionTypeIds.multipleChoice)),
        'Touche la bonne réponse',
      );
      expect(
        labels.describeHint(questionOf(QuestionTypeIds.typedAnswer)),
        isNull,
      );
      expect(
        labels.describeHint(questionOf(QuestionTypeIds.trueFalse)),
        isNotEmpty,
      );
    });
    test('asks the missing number as a number answer', () {
      // Assert
      expect(
        questionOf(QuestionTypeIds.missingNumber).expectedAnswer,
        isA<NumberAnswer>(),
      );
    });
    test('asks to find the hidden number without naming the unit', () {
      // Arrange
      final Question inputDivision = questionOf(QuestionTypeIds.missingNumber);
      final Question inputMultiplication = MultiplicationDomain().buildQuestion(
        item: MultiplicationDomain().findItem('mul:7x8')!,
        questionTypeId: QuestionTypeIds.missingNumber,
        random: DartRandomSource(seed: 3),
      );
      // Assert
      expect(
        labels.describeQuestion(inputDivision, 'division'),
        'Trouve le nombre caché',
      );
      expect(
        labels.describeQuestion(inputMultiplication, 'multiplication'),
        'Trouve le nombre caché',
      );
      final Question inputAddition = AdditionDomain().buildQuestion(
        item: AdditionDomain().findItem('add:7+8')!,
        questionTypeId: QuestionTypeIds.missingNumber,
        random: DartRandomSource(seed: 3),
      );
      expect(
        labels.describeQuestion(inputAddition, 'addition'),
        'Trouve le nombre caché',
      );
      expect(
        labels.describeQuestion(inputAddition, 'mixed'),
        'Trouve le nombre caché',
      );
      expect(
        QuizLabels(
          domains: buildDomainRegistry(),
          l10n: AppLocalizationsEn(),
        ).describeQuestion(inputDivision, 'division'),
        'Find the hidden number',
      );
      expect(
        labels.describeQuestion(
          questionOf(QuestionTypeIds.typedAnswer),
          'division',
        ),
        'Diviser par 7',
      );
    });
  });
}
