import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/services/seeded_random_source.dart';

void main() {
  group('SeededRandomSource', () {
    test('draws the Mulberry32 sequence of the reference algorithm', () {
      // Arrange
      final SeededRandomSource inputSource = SeededRandomSource(seed: 12345);
      // Reference values computed with the JavaScript Mulberry32.
      const List<int> expectedValues = <int>[
        4207900869,
        1317490944,
        2079646450,
        3513001552,
        2187978186,
      ];
      // Act
      final List<int> actualValues = List<int>.generate(
        expectedValues.length,
        (int index) => inputSource.nextUint32(),
      );
      // Assert
      expect(actualValues, expectedValues);
    });
    test('starts from seed 0 like the reference algorithm', () {
      // Arrange
      final SeededRandomSource inputSource = SeededRandomSource(seed: 0);
      // Act
      final List<int> actualValues = <int>[
        inputSource.nextUint32(),
        inputSource.nextUint32(),
        inputSource.nextUint32(),
      ];
      // Assert
      expect(actualValues, <int>[1144304738, 1416247, 958946056]);
    });
    test('nextInt stays below its bound and refuses an empty range', () {
      // Arrange
      final SeededRandomSource inputSource = SeededRandomSource(seed: 7);
      // Act
      final List<int> actualValues = List<int>.generate(
        200,
        (int index) => inputSource.nextInt(6),
      );
      // Assert
      expect(
        actualValues.every((int value) => value >= 0 && value < 6),
        isTrue,
      );
      expect(actualValues.toSet(), hasLength(6));
      expect(() => inputSource.nextInt(0), throwsRangeError);
    });
    test('shuffles the same way for the same seed, input untouched', () {
      // Arrange
      const List<int> inputItems = <int>[1, 2, 3, 4, 5, 6, 7, 8];
      // Act
      final List<int> actualFirst = SeededRandomSource(
        seed: 99,
      ).shuffled(inputItems);
      final List<int> actualSecond = SeededRandomSource(
        seed: 99,
      ).shuffled(inputItems);
      // Assert
      expect(actualFirst, actualSecond);
      expect(actualFirst.toSet(), inputItems.toSet());
      expect(inputItems, <int>[1, 2, 3, 4, 5, 6, 7, 8]);
    });
  });
}
