import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';
import 'package:kid_matix/features/multiplication/domain/services/distractor_generator.dart';

const DistractorGenerator _generator = DistractorGenerator();

List<MultiplicationFact> _buildAllFacts() {
  return <MultiplicationFact>[
    for (int table = 1; table <= 12; table++)
      for (int multiplier = 1; multiplier <= 10; multiplier++)
        MultiplicationFact(table: table, multiplier: multiplier),
  ];
}

void main() {
  group('DistractorGenerator', () {
    test('gives 3 distinct positive wrong answers for the 120 facts', () {
      // Arrange
      final List<String> actualProblems = <String>[];
      // Act
      for (int seed = 0; seed < 20; seed++) {
        final DartRandomSource inputRandom = DartRandomSource(seed: seed);
        for (final MultiplicationFact fact in _buildAllFacts()) {
          final List<int> distractors = _generator.generate(
            fact: fact,
            random: inputRandom,
          );
          final bool isValid =
              distractors.length == 3 &&
              distractors.toSet().length == 3 &&
              !distractors.contains(fact.product) &&
              distractors.every((int value) => value >= 1);
          if (!isValid) actualProblems.add('$fact seed $seed: $distractors');
        }
      }
      // Assert
      expect(actualProblems, isEmpty);
    });
    test('draws the plausible mistakes of 7 x 8', () {
      // Arrange
      const MultiplicationFact inputFact = MultiplicationFact(
        table: 7,
        multiplier: 8,
      );
      const Set<int> expectedCandidates = <int>{49, 63, 48, 64, 15, 65};
      final Set<int> actualDrawn = <int>{};
      // Act
      for (int seed = 0; seed < 50; seed++) {
        actualDrawn.addAll(
          _generator.generate(
            fact: inputFact,
            random: DartRandomSource(seed: seed),
          ),
        );
      }
      // Assert
      expect(actualDrawn, expectedCandidates);
    });
    test('completes with close numbers when mistakes are scarce', () {
      // Arrange
      const MultiplicationFact inputFact = MultiplicationFact(
        table: 1,
        multiplier: 1,
      );
      // Act
      final List<int> actualDistractors = _generator.generate(
        fact: inputFact,
        random: DartRandomSource(seed: 1),
      );
      // Assert
      expect(actualDistractors.toSet(), <int>{2, 3, 4});
    });
    test('never swaps the digits of a three-digit result', () {
      // Arrange
      const MultiplicationFact inputFact = MultiplicationFact(
        table: 12,
        multiplier: 9,
      );
      // Act
      final Set<int> actualDrawn = <int>{
        for (int seed = 0; seed < 50; seed++)
          ..._generator.generate(
            fact: inputFact,
            random: DartRandomSource(seed: seed),
          ),
      };
      // Assert
      expect(actualDrawn, isNot(contains(801)));
    });
    test('draws the same wrong answers with the same seed', () {
      // Arrange
      const MultiplicationFact inputFact = MultiplicationFact(
        table: 6,
        multiplier: 7,
      );
      // Act
      final List<int> actualFirst = _generator.generate(
        fact: inputFact,
        random: DartRandomSource(seed: 42),
      );
      final List<int> actualSecond = _generator.generate(
        fact: inputFact,
        random: DartRandomSource(seed: 42),
      );
      // Assert
      expect(actualFirst, actualSecond);
    });
  });
}
