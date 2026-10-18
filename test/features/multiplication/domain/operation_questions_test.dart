import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_table.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/multiplication/domain/services/operation_distractor_generator.dart';

/// Result of an operation answer such as `4 × 6`.
int _productOf(Answer answer) {
  final List<PromptToken> operation = (answer as OperationAnswer).operation;
  expect(operation[1], const OperatorToken(MathOperator.multiply));
  return (operation[0] as NumberToken).value *
      (operation[2] as NumberToken).value;
}

void main() {
  final MultiplicationDomain domain = MultiplicationDomain();
  final List<MultiplicationFact> allFacts = <MultiplicationFact>[
    for (final MultiplicationTable table in domain.tables) ...table.facts,
  ];
  const List<int> seeds = <int>[1, 2, 3, 4, 5];

  Question build(MultiplicationFact fact, String typeId, int seed) {
    return domain.buildQuestion(
      item: fact,
      questionTypeId: typeId,
      random: DartRandomSource(seed: seed),
    );
  }

  test('the domain supports both formats of version 1.1', () {
    // Assert
    expect(
      domain.questionTypeIds,
      containsAll(<String>[
        QuestionTypeIds.findOperation,
        QuestionTypeIds.matchPairs,
      ]),
    );
  });

  group('find the operation', () {
    test('asks which operation gives the result: ? = 56', () {
      // Act
      final Question actualQuestion = build(
        const MultiplicationFact(table: 7, multiplier: 8),
        QuestionTypeIds.findOperation,
        1,
      );
      // Assert
      expect(actualQuestion.itemKey, 'mul:7x8');
      expect(actualQuestion.unitKey, 'mul:7');
      expect(actualQuestion.questionTypeId, QuestionTypeIds.findOperation);
      expect(actualQuestion.prompt, const <PromptToken>[
        BlankToken(),
        EqualsToken(),
        NumberToken(56),
      ]);
      expect(
        actualQuestion.expectedAnswer,
        OperationAnswer(const <PromptToken>[
          NumberToken(7),
          OperatorToken(MathOperator.multiply),
          NumberToken(8),
        ]),
      );
      expect(actualQuestion.pairs, isEmpty);
    });
    test('offers exactly one right operation among 4 distinct ones', () {
      for (final int seed in seeds) {
        for (final MultiplicationFact fact in allFacts) {
          // Act
          final Question actualQuestion = build(
            fact,
            QuestionTypeIds.findOperation,
            seed,
          );
          // Assert
          final List<int> actualProducts = actualQuestion.choices
              .map(_productOf)
              .toList();
          expect(actualQuestion.choices, hasLength(4), reason: fact.key);
          expect(actualQuestion.choices.toSet(), hasLength(4));
          expect(actualProducts.toSet(), hasLength(4), reason: fact.key);
          expect(
            actualProducts.where((int product) => product == fact.product),
            hasLength(1),
            reason: fact.key,
          );
          expect(
            actualQuestion.choices,
            contains(actualQuestion.expectedAnswer),
          );
        }
      }
    });
    test('draws only facts of the tables, near the right one', () {
      // Act
      final Question actualQuestion = build(
        const MultiplicationFact(table: 4, multiplier: 6),
        QuestionTypeIds.findOperation,
        3,
      );
      // Assert
      for (final Answer choice in actualQuestion.choices) {
        final List<PromptToken> operation =
            (choice as OperationAnswer).operation;
        final int table = (operation[0] as NumberToken).value;
        final int multiplier = (operation[2] as NumberToken).value;
        expect(table, inInclusiveRange(2, 6));
        expect(multiplier, inInclusiveRange(4, 8));
      }
    });
    test('puts the right operation at a random place', () {
      // Act
      final Set<int> actualPlaces = <int>{
        for (final int seed in <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
          () {
            final Question question = build(
              const MultiplicationFact(table: 6, multiplier: 7),
              QuestionTypeIds.findOperation,
              seed,
            );
            return question.choices.indexOf(question.expectedAnswer);
          }(),
      };
      // Assert
      expect(actualPlaces.length, greaterThan(1));
    });
  });

  group('OperationDistractorGenerator', () {
    test('falls back on the closest results when neighbors run out', () {
      // Arrange
      const OperationDistractorGenerator inputGenerator =
          OperationDistractorGenerator(lastTable: 1, lastMultiplier: 4);
      // Act
      final List<MultiplicationFact> actualDistractors = inputGenerator
          .generate(
            fact: const MultiplicationFact(table: 1, multiplier: 1),
            random: DartRandomSource(seed: 1),
          );
      // Assert
      expect(
        actualDistractors.map((MultiplicationFact fact) => fact.product),
        unorderedEquals(<int>[2, 3, 4]),
      );
    });
  });

  group('match the pairs', () {
    test('ties 4 facts of the table of the item to their results', () {
      for (final int seed in seeds) {
        for (final MultiplicationFact fact in allFacts) {
          // Act
          final Question actualQuestion = build(
            fact,
            QuestionTypeIds.matchPairs,
            seed,
          );
          // Assert
          final List<QuestionPair> actualPairs = actualQuestion.pairs;
          expect(actualPairs, hasLength(4), reason: fact.key);
          expect(actualQuestion.itemKeys.toSet(), hasLength(4));
          expect(actualQuestion.itemKeys, contains(fact.key));
          expect(
            actualPairs.map((QuestionPair pair) => pair.result).toSet(),
            hasLength(4),
            reason: fact.key,
          );
          expect(
            actualQuestion.choices,
            unorderedEquals(
              actualPairs.map((QuestionPair pair) => pair.result),
            ),
          );
          for (final QuestionPair pair in actualPairs) {
            final MultiplicationFact pairFact = domain.findItem(pair.itemKey)!;
            expect(pairFact.table, fact.table);
            expect(pair.result, NumberAnswer(pairFact.product));
            expect(_productOf(pair.operation), pairFact.product);
          }
        }
      }
    });
    test('expects every pair matched without a mistake', () {
      // Act
      final Question actualQuestion = build(
        const MultiplicationFact(table: 3, multiplier: 4),
        QuestionTypeIds.matchPairs,
        1,
      );
      // Assert
      expect(actualQuestion.itemKey, 'mul:3x4');
      expect(actualQuestion.unitKey, 'mul:3');
      expect(actualQuestion.questionTypeId, QuestionTypeIds.matchPairs);
      expect(actualQuestion.expectedAnswer, PairsAnswer());
      expect(actualQuestion.prompt, isEmpty);
    });
  });
}
