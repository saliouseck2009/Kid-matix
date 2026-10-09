import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';

void main() {
  group('DartRandomSource', () {
    test('two sources with the same seed draw the same numbers', () {
      // Arrange
      const int inputSeed = 7;
      const int inputMax = 100;
      final DartRandomSource inputFirst = DartRandomSource(seed: inputSeed);
      final DartRandomSource inputSecond = DartRandomSource(seed: inputSeed);
      // Act
      final List<int> actualFirst = List<int>.generate(
        10,
        (int index) => inputFirst.nextInt(inputMax),
      );
      final List<int> actualSecond = List<int>.generate(
        10,
        (int index) => inputSecond.nextInt(inputMax),
      );
      // Assert
      expect(actualFirst, actualSecond);
    });
    test('shuffled keeps every item and leaves the input untouched', () {
      // Arrange
      const List<int> inputItems = <int>[1, 2, 3, 4, 5, 6];
      final DartRandomSource inputSource = DartRandomSource(seed: 3);
      // Act
      final List<int> actualItems = inputSource.shuffled(inputItems);
      // Assert
      expect(actualItems, unorderedEquals(inputItems));
      expect(inputItems, <int>[1, 2, 3, 4, 5, 6]);
    });
  });
}
