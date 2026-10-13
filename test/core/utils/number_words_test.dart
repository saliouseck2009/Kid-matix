import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/utils/english_number_words.dart';
import 'package:kid_matix/core/utils/number_words.dart';
import 'package:kid_matix/core/utils/spanish_number_words.dart';

void main() {
  group('EnglishNumberWords', () {
    test('spells numbers the American way', () {
      // Arrange
      const Map<int, String> expectedWords = <int, String>{
        0: 'zero',
        13: 'thirteen',
        20: 'twenty',
        21: 'twenty-one',
        99: 'ninety-nine',
        100: 'one hundred',
        347: 'three hundred forty-seven',
        1000: 'one thousand',
        1015: 'one thousand fifteen',
        2200: 'two thousand two hundred',
        7998: 'seven thousand nine hundred ninety-eight',
        80000: 'eighty thousand',
        999999: 'nine hundred ninety-nine thousand nine hundred ninety-nine',
      };
      // Act
      final Map<int, String> actualWords = <int, String>{
        for (final int number in expectedWords.keys)
          number: EnglishNumberWords.spell(number),
      };
      // Assert
      expect(actualWords, expectedWords);
    });
  });

  group('SpanishNumberWords', () {
    test('spells numbers in Spanish', () {
      // Arrange
      const Map<int, String> expectedWords = <int, String>{
        0: 'cero',
        16: 'dieciséis',
        21: 'veintiuno',
        22: 'veintidós',
        31: 'treinta y uno',
        100: 'cien',
        101: 'ciento uno',
        347: 'trescientos cuarenta y siete',
        500: 'quinientos',
        715: 'setecientos quince',
        1000: 'mil',
        1001: 'mil uno',
        2900: 'dos mil novecientos',
        7998: 'siete mil novecientos noventa y ocho',
        21000: 'veintiún mil',
        31000: 'treinta y un mil',
        100000: 'cien mil',
        101000: 'ciento un mil',
      };
      // Act
      final Map<int, String> actualWords = <int, String>{
        for (final int number in expectedWords.keys)
          number: SpanishNumberWords.spell(number),
      };
      // Assert
      expect(actualWords, expectedWords);
    });
  });

  group('NumberWords', () {
    test('spells in the language of the interface, French otherwise', () {
      // Act
      final List<String> actualWords = <String>[
        for (final String code in <String>['fr', 'en', 'es', 'de'])
          NumberWords.spell(1080, languageCode: code),
      ];
      // Assert
      expect(actualWords, <String>[
        'mille quatre-vingts',
        'one thousand eighty',
        'mil ochenta',
        'mille quatre-vingts',
      ]);
    });
  });
}
