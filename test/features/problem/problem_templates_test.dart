import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/currency.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_instance.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_templates.dart';

/// The numbers of every template, over every value its ranges allow
/// (F30-02, F30-10): each story keeps its model true, its answer whole and
/// positive, its numbers under the cap of the level, and one operation
/// only that gives the answer.
void main() {
  /// The relation the bar model of each shape holds.
  bool holds(BarModelPicture picture) {
    final Map<BarRole, int> v = picture.values;
    return switch (picture.shape) {
      BarModelShape.partWhole =>
        v[BarRole.whole] == v[BarRole.partA]! + v[BarRole.partB]!,
      BarModelShape.compare =>
        v[BarRole.big] == v[BarRole.small]! + v[BarRole.gap]!,
      BarModelShape.groups =>
        v[BarRole.total] == v[BarRole.groups]! * v[BarRole.each]!,
      BarModelShape.ratio =>
        v[BarRole.big] == v[BarRole.small]! * v[BarRole.times]!,
    };
  }

  /// Every operation that gives [answer] from the two known numbers.
  Set<MathOperator> operationsGiving(BarModelPicture picture) {
    final List<int> known = <int>[
      for (final BarRole role in picture.knownRoles) picture.values[role]!,
    ];
    final int answer = picture.answer;
    bool gives(int x, int y, MathOperator operator) => switch (operator) {
      MathOperator.add => x + y == answer,
      MathOperator.subtract => x - y == answer,
      MathOperator.multiply => x * y == answer,
      _ => y != 0 && x % y == 0 && x ~/ y == answer,
    };
    return <MathOperator>{
      for (final MathOperator operator in <MathOperator>[
        MathOperator.add,
        MathOperator.subtract,
        MathOperator.multiply,
        MathOperator.divide,
      ])
        if (gives(known[0], known[1], operator) ||
            gives(known[1], known[0], operator))
          operator,
    };
  }

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
          final ProblemInstance instance = template.drawnInstance(
            (int count) => template.validValues.indexOf(values),
          );
          // Assert
          expect(holds(instance.picture), isTrue, reason: '$values');
          expect(instance.answer, greaterThan(0));
          expect(
            operationsGiving(instance.picture),
            <MathOperator>{template.operation},
            reason: '$values',
          );
        }
      });

      test('writes every number and no placeholder in its statement', () {
        for (final ProblemInstance instance in <ProblemInstance>[
          template.fixedInstance(),
          template.drawnInstance((int count) => count - 1),
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
