import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/number/domain/services/number_distractor_generator.dart';

void main() {
  const NumberDistractorGenerator generator = NumberDistractorGenerator();

  test('keeps the typical mistake and draws the others', () {
    for (int seed = 0; seed < 10; seed++) {
      // Act
      final List<int> actual = generator.generate(
        answer: 34,
        mistakes: const <int>[7, 24, 44, 33, 35],
        typicalMistake: 43,
        random: DartRandomSource(seed: seed),
      );
      // Assert
      expect(actual, hasLength(3));
      expect(actual.first, 43);
      expect(actual.toSet(), hasLength(3));
      expect(actual, isNot(contains(34)));
    }
  });
  test('leaves out the answer, duplicates and numbers out of range', () {
    // Act
    final List<int> actual = generator.generate(
      answer: 1,
      mistakes: const <int>[0, -1, 1, 2, 2, 200],
      random: DartRandomSource(seed: 1),
    );
    // Assert
    expect(actual, hasLength(3));
    expect(actual.first, 2);
    expect(actual.toSet(), hasLength(3));
    for (final int value in actual) {
      expect(value, inInclusiveRange(1, NumberDistractorGenerator.largest));
      expect(value, isNot(1));
    }
  });
  test('completes with the numbers next to the answer', () {
    // Act
    final List<int> actual = generator.generate(
      answer: 100,
      mistakes: const <int>[],
      random: DartRandomSource(seed: 1),
    );
    // Assert
    expect(actual, <int>[101, 99, 102]);
  });
}
