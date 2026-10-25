import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/currency.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_instance.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_templates.dart';

import 'helpers/problem_checks.dart';

/// The numbers of every template, over every value its ranges allow
/// (F30-02, F30-10): each story keeps its model true, its answer whole and
/// positive, its numbers under the cap of the level, and one operation
/// only that gives the answer.
void main() {
  for (final ProblemTemplate template in ProblemTemplates.all) {
    group(template.problemKey, () {
      test('draws many numbers, all in the cap of its level', () {
        // Arrange
        final int cap = ProblemTemplate.levelCaps[template.level]!;
        // Assert
        expect(template.validValues, isNotEmpty);
        for (final Map<String, int> values in template.validValues) {
          for (final MapEntry<String, int> entry in values.entries) {
            expect(
              entry.value,
              inInclusiveRange(1, cap),
              reason: '${entry.key} in $values',
            );
          }
        }
      });

      test('holds its bar model and one operation for every draw', () {
        for (final Map<String, int> values in template.validValues) {
          // Act
          final ProblemInstance instance = template.instanceOf(values);
          // Assert
          expect(modelHolds(instance.picture), isTrue, reason: '$values');
          expect(instance.answer, greaterThan(0));
          expect(
            operationsGiving(instance.picture),
            <MathOperator>{template.operation},
            reason: '$values',
          );
        }
      });

      test('draws valid numbers one placeholder after the other', () {
        // Arrange
        final RandomSource random = DartRandomSource(seed: 11);
        // Act
        final List<ProblemInstance> drawn = <ProblemInstance>[
          for (int i = 0; i < 60; i++) template.drawnInstance(random),
        ];
        // Assert
        for (final ProblemInstance instance in drawn) {
          expect(
            template.validValues.any(
              (Map<String, int> v) => mapEquals(v, instance.values),
            ),
            isTrue,
            reason: '${instance.values}',
          );
          expect(instance.isRecorded, isFalse);
        }
      });

      test('falls back on the list when every try is rejected', () {
        // Act: a draw that always takes the last option breaks the cap of
        // some templates; the answer still is a valid set of numbers.
        final ProblemInstance actual = template.drawnInstance(
          _LastOptionRandom(),
        );
        // Assert
        expect(template.isValid(actual.values), isTrue);
      });

      test('writes every number and no placeholder in its statement', () {
        for (final ProblemInstance instance in <ProblemInstance>[
          template.fixedInstance(),
          template.drawnInstance(DartRandomSource(seed: 9)),
        ]) {
          // Assert
          expect(instance.statement, isNot(contains('{')));
          expect(instance.picture.check, isNot(contains('{')));
          expect(instance.picture.check, contains('${instance.answer}'));
        }
      });
    });
  }

  test('keeps the sums of money in multiples of 25 up to 100 francs', () {
    // Arrange
    final List<ProblemTemplate> money = ProblemTemplates.all
        .where((ProblemTemplate p) => p.statement.contains('{currency}'))
        .toList();
    // Assert
    expect(money, hasLength(3));
    for (final ProblemTemplate problem in money) {
      expect(problem.level, 3);
      for (final Map<String, int> values in problem.validValues) {
        for (final int value in values.values) {
          expect(value % 25, 0, reason: '${problem.problemKey} $values');
          expect(value, lessThanOrEqualTo(100));
        }
      }
    }
  });

  test('writes francs by default and another currency in one place', () {
    // Arrange
    final ProblemTemplate problem = ProblemTemplates.all.firstWhere(
      (ProblemTemplate p) => p.problemKey == 'achat_sachet_eau',
    );
    const Currency other = Currency(code: 'XXX', unitName: 'dalasis');
    // Assert
    expect(Currency.defaultCurrency, Currency.cfaFranc);
    expect(problem.fixedInstance().statement, contains('100 francs'));
    expect(problem.fixedInstance().picture.check, contains('francs'));
    expect(
      problem.fixedInstance(currency: other).statement,
      allOf(contains('100 dalasis'), isNot(contains('francs'))),
    );
  });
}

/// A draw that always takes the last option, which breaks the cap of some
/// templates and so exercises the fallback.
final class _LastOptionRandom implements RandomSource {
  @override
  int nextInt(int max) => max - 1;

  @override
  List<T> shuffled<T>(List<T> items) => List<T>.of(items);
}
