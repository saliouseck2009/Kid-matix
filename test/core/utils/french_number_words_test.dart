import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/utils/french_number_words.dart';

void main() {
  group('FrenchNumberWords', () {
    test('spells numbers in the traditional French spelling', () {
      // Arrange
      const Map<int, String> expectedWords = <int, String>{
        0: 'zéro',
        16: 'seize',
        17: 'dix-sept',
        21: 'vingt et un',
        22: 'vingt-deux',
        70: 'soixante-dix',
        71: 'soixante et onze',
        77: 'soixante-dix-sept',
        80: 'quatre-vingts',
        81: 'quatre-vingt-un',
        91: 'quatre-vingt-onze',
        100: 'cent',
        180: 'cent quatre-vingts',
        200: 'deux cents',
        201: 'deux cent un',
        347: 'trois cent quarante-sept',
        1000: 'mille',
        1080: 'mille quatre-vingts',
        2200: 'deux mille deux cents',
        7998: 'sept mille neuf cent quatre-vingt-dix-huit',
        80000: 'quatre-vingt mille',
        200000: 'deux cent mille',
      };
      // Act
      final Map<int, String> actualWords = <int, String>{
        for (final int number in expectedWords.keys)
          number: FrenchNumberWords.spell(number),
      };
      // Assert
      expect(actualWords, expectedWords);
    });
  });
}
