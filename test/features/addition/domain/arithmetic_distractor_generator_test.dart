import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/addition/domain/entities/arithmetic_fact.dart';
import 'package:kid_matix/features/addition/domain/services/addition_domain.dart';
import 'package:kid_matix/features/addition/domain/services/arithmetic_distractor_generator.dart';

void main() {
  const ArithmeticDistractorGenerator generator =
      ArithmeticDistractorGenerator();
  final List<ArithmeticFact> allFacts = <ArithmeticFact>[
    for (final LearningUnit unit in AdditionDomain().units)
      for (final LearningItem item in unit.items) item as ArithmeticFact,
  ];

  test('gives distinct, never negative wrong answers for every fact', () {
    for (final ArithmeticFact fact in allFacts) {
      for (int seed = 0; seed < 8; seed++) {
        for (final int count in <int>[1, 3, 5]) {
          // Act
          final List<int> actual = generator.generate(
            fact: fact,
            random: DartRandomSource(seed: seed),
            count: count,
          );
          // Assert
          final String reason = '${fact.key} seed $seed count $count';
          expect(actual, hasLength(count), reason: reason);
          expect(actual.toSet(), hasLength(count), reason: reason);
          expect(actual, isNot(contains(fact.result)), reason: reason);
          for (final int value in actual) {
            expect(value, greaterThanOrEqualTo(0), reason: reason);
            expect(
              value,
              lessThanOrEqualTo(ArithmeticDistractorGenerator.largest),
              reason: reason,
            );
          }
        }
      }
    }
  });
  test('offers the forgotten carry first for an addition with a carry', () {
    for (int seed = 0; seed < 6; seed++) {
      // Act
      final List<int> actual = generator.generate(
        fact: const ArithmeticFact.add(27, 15),
        random: DartRandomSource(seed: seed),
      );
      // Assert
      expect(actual.first, 32);
    }
    expect(
      generator.typicalMistake(const ArithmeticFact.add(7, 8)),
      5,
    );
  });
  test('offers the forgotten borrow first for a subtraction with a borrow', () {
    // Assert
    expect(generator.typicalMistake(const ArithmeticFact.subtract(42, 17)), 35);
    expect(generator.typicalMistake(const ArithmeticFact.subtract(15, 7)), 12);
    expect(
      generator
          .generate(
            fact: const ArithmeticFact.subtract(42, 17),
            random: DartRandomSource(seed: 2),
          )
          .first,
      35,
    );
  });
  test('has no typical mistake without a carry or a borrow', () {
    // Assert
    expect(generator.typicalMistake(const ArithmeticFact.add(23, 14)), isNull);
    expect(
      generator.typicalMistake(const ArithmeticFact.subtract(47, 23)),
      isNull,
    );
  });
  test('lists the swapped digits, the other operation and the neighbors', () {
    // Act
    final List<int> actual = generator.mistakesOf(
      const ArithmeticFact.add(27, 15),
    );
    // Assert
    expect(actual, containsAll(<int>[32, 24, 12, 41, 43, 52, 32]));
    expect(
      generator.mistakesOf(const ArithmeticFact.subtract(15, 7)),
      containsAll(<int>[12, 22, 7, 9, 18, -2]),
    );
  });
  test(
    'never swaps the digits of a number that ends in 0 or has one digit',
    () {
      // Assert
      expect(
        generator.mistakesOf(const ArithmeticFact.add(5, 5)),
        isNot(contains(1)),
      );
      expect(
        generator.mistakesOf(const ArithmeticFact.add(44, 44)),
        isNot(contains(88)),
      );
    },
  );
  test('completes with the numbers around an answer of 0 or near the top', () {
    // Act
    final List<int> actual = generator.generate(
      fact: const ArithmeticFact.subtract(9, 9),
      random: DartRandomSource(seed: 1),
    );
    // Assert
    expect(actual.toSet(), hasLength(3));
    expect(actual, isNot(contains(0)));
    expect(actual.every((int value) => value >= 0), isTrue);
  });
}
