/// Folds a text for comparisons that ignore case and accents: « ÀWA »,
/// « awa » and « Awa » fold the same.
///
/// Shared by the uniqueness of the nicknames (profile) and the search of
/// a pupil in a class (class mode). Pure Dart.
abstract final class TextFolding {
  static const Map<String, String> _plainLetters = <String, String>{
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

  /// [input] in lower case, without accents.
  static String fold(String input) {
    final StringBuffer buffer = StringBuffer();
    for (final String character in input.toLowerCase().split('')) {
      buffer.write(_plainLetters[character] ?? character);
    }
    return buffer.toString();
  }
}
