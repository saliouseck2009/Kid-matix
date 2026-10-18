import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/division/domain/entities/division_fact.dart';
import 'package:kid_matix/features/division/domain/entities/division_unit.dart';
import 'package:kid_matix/features/division/domain/services/division_distractor_generator.dart';
import 'package:kid_matix/features/division/domain/services/division_domain.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_table.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

/// Dividends of every unit as released: `div:<dividend>/<divisor>`. A
/// change here loses the progress of the children.
const Map<int, List<int>> _releasedDividends = <int, List<int>>{
  1: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
  2: <int>[2, 4, 6, 8, 10, 12, 14, 16, 18, 20],
  3: <int>[3, 6, 9, 12, 15, 18, 21, 24, 27, 30],
  4: <int>[4, 8, 12, 16, 20, 24, 28, 32, 36, 40],
  5: <int>[5, 10, 15, 20, 25, 30, 35, 40, 45, 50],
  6: <int>[6, 12, 18, 24, 30, 36, 42, 48, 54, 60],
  7: <int>[7, 14, 21, 28, 35, 42, 49, 56, 63, 70],
  8: <int>[8, 16, 24, 32, 40, 48, 56, 64, 72, 80],
  9: <int>[9, 18, 27, 36, 45, 54, 63, 72, 81, 90],
  10: <int>[10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
  11: <int>[11, 22, 33, 44, 55, 66, 77, 88, 99, 110],
  12: <int>[12, 24, 36, 48, 60, 72, 84, 96, 108, 120],
};

void main() {
  final DivisionDomain domain = DivisionDomain();
  final MultiplicationDomain multiplication = MultiplicationDomain();

  group('keys', () {
    test('pins the key of every division and of every unit', () {
      // Act
      final Map<String, List<String>> actual = <String, List<String>>{
        for (final LearningUnit unit in domain.units)
          unit.key: unit.items.map((LearningItem item) => item.key).toList(),
      };
      // Assert
      expect(actual, <String, List<String>>{
        for (final MapEntry<int, List<int>> unit in _releasedDividends.entries)
          'div:${unit.key}': <String>[
            for (final int dividend in unit.value) 'div:$dividend/${unit.key}',
          ],
      });
    });
    test('writes 56 ÷ 7 as div:56/7 in the unit div:7', () {
      // Act
      final DivisionFact? actual = domain.findItem('div:56/7');
      // Assert
      expect(actual, const DivisionFact(divisor: 7, quotient: 8));
      expect(domain.findUnit('div:7')!.items, contains(actual));
    });
    test('computes the 120 divisions from the 120 multiplication facts', () {
      // Arrange
      final List<MultiplicationFact> facts = <MultiplicationFact>[
        for (final MultiplicationTable table in multiplication.tables)
          ...table.facts,
      ];
      // Act
      final Set<String> actualKeys = <String>{
        for (final DivisionUnit unit in domain.units)
          for (final DivisionFact fact in unit.facts) fact.key,
      };
      // Assert
      expect(facts, hasLength(120));
      expect(actualKeys, <String>{
        for (final MultiplicationFact fact in facts)
          'div:${fact.product}/${fact.table}',
      });
    });
    test('keeps the units in the order of the multiplication path', () {
      // Assert
      expect(
        domain.path.map((LearningUnit unit) => unit.number),
        multiplication.path.map((LearningUnit table) => table.number),
      );
      expect(DivisionDomain.unitCount, MultiplicationDomain.tableCount);
      expect(DivisionDomain.lastQuotient, MultiplicationDomain.lastMultiplier);
    });
    test('has no key twice and none that finds nothing back', () {
      // Act
      final List<String> actual = <String>[
        for (final LearningUnit unit in domain.units)
          for (final LearningItem item in unit.items) item.key,
      ];
      // Assert
      expect(actual.toSet(), hasLength(120));
      expect(actual.every((String key) => domain.findItem(key) != null), true);
      expect(domain.findItem('mul:7x8'), isNull);
      expect(domain.findItem('div:57/7'), isNull);
      expect(domain.findUnit('div:13'), isNull);
    });
  });

  group('weights', () {
    test('draws the quotients 1 and 10 half as often outside their unit', () {
      // Assert
      expect(domain.drawWeightOf(domain.findItem('div:7/7')!), 1);
      expect(domain.drawWeightOf(domain.findItem('div:70/7')!), 1);
      expect(domain.drawWeightOf(domain.findItem('div:56/7')!), 2);
      expect(domain.drawWeightOf(domain.findItem('div:10/1')!), 2);
      expect(domain.drawWeightOf(domain.findItem('div:100/10')!), 2);
    });
    test('refuses an item that is not a division', () {
      // Assert
      expect(
        () => domain.drawWeightOf(
          const MultiplicationFact(table: 7, multiplier: 8),
        ),
        throwsArgumentError,
      );
    });
  });

  group('questions', () {
    final DivisionFact fact = domain.findItem('div:56/7')!;

    String show(List<PromptToken> prompt) {
      return prompt
          .map(
            (PromptToken token) => switch (token) {
              NumberToken(:final int value) => '$value',
              OperatorToken() => '÷',
              EqualsToken() => '=',
              BlankToken() => '?',
            },
          )
          .join(' ');
    }

    test('offers four formats to every division', () {
      // Assert
      expect(domain.questionTypeIdsOf(fact), <String>[
        QuestionTypeIds.multipleChoice,
        QuestionTypeIds.typedAnswer,
        QuestionTypeIds.missingNumber,
        QuestionTypeIds.trueFalse,
      ]);
    });
    test('builds 56 ÷ 7 = ? with the quotient among four numbers', () {
      // Act
      final Question actual = domain.buildQuestion(
        item: fact,
        questionTypeId: QuestionTypeIds.multipleChoice,
        random: DartRandomSource(seed: 2),
      );
      // Assert
      expect(show(actual.prompt), '56 ÷ 7 = ?');
      expect(actual.expectedAnswer, const NumberAnswer(8));
      expect(actual.choices, hasLength(4));
      expect(actual.choices, contains(const NumberAnswer(8)));
      expect(actual.itemKey, 'div:56/7');
      expect(actual.unitKey, 'div:7');
    });
    test('builds 56 ÷ 7 = ? to write on the keypad', () {
      // Act
      final Question actual = domain.buildQuestion(
        item: fact,
        questionTypeId: QuestionTypeIds.typedAnswer,
        random: DartRandomSource(seed: 2),
      );
      // Assert
      expect(show(actual.prompt), '56 ÷ 7 = ?');
      expect(actual.expectedAnswer, const NumberAnswer(8));
      expect(actual.choices, isEmpty);
    });
    test('hides the divisor or the dividend of the missing number', () {
      // Act
      final Set<String> actualPrompts = <String>{};
      for (int seed = 0; seed < 20; seed++) {
        final Question question = domain.buildQuestion(
          item: fact,
          questionTypeId: QuestionTypeIds.missingNumber,
          random: DartRandomSource(seed: seed),
        );
        final String prompt = show(question.prompt);
        actualPrompts.add(prompt);
        // Assert
        expect(
          question.expectedAnswer,
          NumberAnswer(prompt.startsWith('?') ? 56 : 7),
        );
      }
      expect(actualPrompts, <String>{'56 ÷ ? = 8', '? ÷ 7 = 8'});
    });
    test('states a true or a false division', () {
      // Act
      final List<Question> actual = <Question>[
        for (int seed = 0; seed < 20; seed++)
          domain.buildQuestion(
            item: fact,
            questionTypeId: QuestionTypeIds.trueFalse,
            random: DartRandomSource(seed: seed),
          ),
      ];
      // Assert
      for (final Question question in actual) {
        final NumberToken shown = question.prompt.last as NumberToken;
        expect(
          question.expectedAnswer,
          BooleanAnswer(value: shown.value == 8),
          reason: show(question.prompt),
        );
      }
      expect(
        actual.map((Question question) => question.expectedAnswer).toSet(),
        hasLength(2),
      );
    });
    test('refuses a format it cannot build', () {
      // Assert
      expect(
        () => domain.buildQuestion(
          item: fact,
          questionTypeId: QuestionTypeIds.matchPairs,
          random: DartRandomSource(seed: 1),
        ),
        throwsArgumentError,
      );
    });
    test('builds every format of every division with a right answer', () {
      for (final DivisionUnit unit in domain.units) {
        for (final DivisionFact each in unit.facts) {
          for (final String typeId in domain.questionTypeIds) {
            // Act
            final Question actual = domain.buildQuestion(
              item: each,
              questionTypeId: typeId,
              random: DartRandomSource(seed: each.dividend),
            );
            // Assert
            expect(actual.itemKey, each.key);
            expect(actual.unitKey, unit.key);
            if (typeId == QuestionTypeIds.multipleChoice) {
              expect(actual.choices, contains(actual.expectedAnswer));
            }
          }
        }
      }
    });
  });

  group('wrong answers', () {
    const DivisionDistractorGenerator generator = DivisionDistractorGenerator();

    test('never repeat, hold the answer or fall below 1, for all 120', () {
      for (final DivisionUnit unit in domain.units) {
        for (final DivisionFact fact in unit.facts) {
          for (int seed = 0; seed < 5; seed++) {
            // Act
            final List<int> actual = generator.generate(
              fact: fact,
              random: DartRandomSource(seed: seed),
            );
            // Assert
            expect(actual, hasLength(3), reason: fact.key);
            expect(actual.toSet(), hasLength(3), reason: fact.key);
            expect(actual, isNot(contains(fact.quotient)), reason: fact.key);
            expect(actual.every((int value) => value >= 1), true);
          }
        }
      }
    });
    test('offers the divisor, mixed up with the result', () {
      // Act
      final Set<int> actual = <int>{
        for (int seed = 0; seed < 30; seed++)
          ...generator.generate(
            fact: const DivisionFact(divisor: 7, quotient: 8),
            random: DartRandomSource(seed: seed),
          ),
      };
      // Assert
      expect(actual, containsAll(<int>[7, 9, 6]));
    });
    test('finds as many as asked for the smallest quotient', () {
      // Act
      final List<int> actual = generator.generate(
        fact: const DivisionFact(divisor: 1, quotient: 1),
        random: DartRandomSource(seed: 1),
        count: 5,
      );
      // Assert
      expect(actual.toSet(), hasLength(5));
      expect(actual, isNot(contains(1)));
    });
  });
}
