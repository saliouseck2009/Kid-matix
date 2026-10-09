import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_error.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';

void main() {
  group('NicknameRules.clean', () {
    test('trims and reduces inner runs of spaces to one', () {
      // Arrange
      const String inputNickname = '  Awa   Bâ \t';
      const String expectedNickname = 'Awa Bâ';
      // Act
      final String actualNickname = NicknameRules.clean(inputNickname);
      // Assert
      expect(actualNickname, expectedNickname);
    });
  });

  group('NicknameRules.validate', () {
    final Map<String, NicknameError?> expectedErrors = <String, NicknameError?>{
      'Al': null,
      'Moussa': null,
      'Léa 2': null,
      'Abcdefghijkl': null,
      'Çédric': null,
      '  Lina  ': null,
      'A': NicknameError.tooShort,
      '': NicknameError.tooShort,
      '   A   ': NicknameError.tooShort,
      'Abcdefghijklm': NicknameError.tooLong,
      'Awa!': NicknameError.invalidCharacters,
      'Jean-Paul': NicknameError.invalidCharacters,
      "N'Diaye": NicknameError.invalidCharacters,
      'Lina😀': NicknameError.invalidCharacters,
    };
    for (final MapEntry<String, NicknameError?> entry
        in expectedErrors.entries) {
      test('returns ${entry.value} for "${entry.key}"', () {
        // Arrange
        final String inputNickname = entry.key;
        // Act
        final NicknameError? actualError = NicknameRules.validate(
          inputNickname,
        );
        // Assert
        expect(actualError, entry.value);
      });
    }
  });

  group('NicknameRules.normalize', () {
    test('ignores case', () {
      // Arrange
      const String inputNickname = 'Awa';
      const String inputOtherNickname = 'aWA';
      // Act
      final String actualNormalized = NicknameRules.normalize(inputNickname);
      final String actualOtherNormalized = NicknameRules.normalize(
        inputOtherNickname,
      );
      // Assert
      expect(actualNormalized, actualOtherNormalized);
    });
    test('ignores accents', () {
      // Arrange
      const String inputNickname = 'Léa Çœur';
      const String expectedNormalized = 'lea coeur';
      // Act
      final String actualNormalized = NicknameRules.normalize(inputNickname);
      // Assert
      expect(actualNormalized, expectedNormalized);
    });
    test('ignores stray spaces', () {
      // Arrange
      const String inputNickname = ' Awa   Ba ';
      const String expectedNormalized = 'awa ba';
      // Act
      final String actualNormalized = NicknameRules.normalize(inputNickname);
      // Assert
      expect(actualNormalized, expectedNormalized);
    });
    test('keeps two different nicknames apart', () {
      // Arrange
      const String inputNickname = 'Lina';
      const String inputOtherNickname = 'Lena';
      // Act
      final String actualNormalized = NicknameRules.normalize(inputNickname);
      final String actualOtherNormalized = NicknameRules.normalize(
        inputOtherNickname,
      );
      // Assert
      expect(actualNormalized, isNot(actualOtherNormalized));
    });
  });
}
