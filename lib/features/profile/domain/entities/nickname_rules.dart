import 'package:kid_matix/features/profile/domain/entities/nickname_error.dart';

/// Rules of a player's nickname.
///
/// A nickname has 2 to 12 characters: letters (accented ones included),
/// digits and spaces. Two nicknames are the same when their [normalize]d
/// forms are equal, so "Awa", "awa" and "ÀWA" clash.
abstract final class NicknameRules {
  /// Fewest characters a nickname may have.
  static const int minLength = 2;

  /// Most characters a nickname may have.
  static const int maxLength = 12;

  static final RegExp _allowedCharacters = RegExp(
    r'^[\p{L}\p{N} ]+$',
    unicode: true,
  );
  static final RegExp _spaces = RegExp(r'\s+');
  static const Map<String, String> _unaccentedLetters = <String, String>{
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'æ': 'ae',
    'ç': 'c',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ñ': 'n',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'œ': 'oe',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ý': 'y',
    'ÿ': 'y',
  };

  /// Returns [input] without leading or trailing spaces, with every run of
  /// spaces inside reduced to one: the form that is stored and displayed.
  static String clean(String input) {
    return input.trim().replaceAll(_spaces, ' ');
  }

  /// Returns why [input] cannot be a nickname, or `null` when it can.
  ///
  /// [input] is [clean]ed first, so stray spaces never count.
  static NicknameError? validate(String input) {
    final String nickname = clean(input);
    final int length = nickname.runes.length;
    if (length < minLength) return NicknameError.tooShort;
    if (length > maxLength) return NicknameError.tooLong;
    if (!_allowedCharacters.hasMatch(nickname)) {
      return NicknameError.invalidCharacters;
    }
    return null;
  }

  /// Returns the form of [input] used to check uniqueness: [clean]ed,
  /// lower case, and without accents.
  static String normalize(String input) {
    final String lowerCase = clean(input).toLowerCase();
    final StringBuffer buffer = StringBuffer();
    for (final String character in lowerCase.split('')) {
      buffer.write(_unaccentedLetters[character] ?? character);
    }
    return buffer.toString();
  }
}
