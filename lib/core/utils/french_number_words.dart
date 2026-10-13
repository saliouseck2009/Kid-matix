/// Writes a whole number in French words, in the traditional spelling:
/// 347 is "trois cent quarante-sept", 80 "quatre-vingts", 71 "soixante
/// et onze", 2000 "deux mille".
///
/// The parental gate shows a number this way. Each language needs its
/// own rules; this one serves the French interface.
abstract final class FrenchNumberWords {
  /// Largest number spelled.
  static const int maxNumber = 999999;

  static const int _ten = 10;
  static const int _seventeen = 17;
  static const int _twenty = 20;
  static const int _sixty = 60;
  static const int _seventy = 70;
  static const int _seventyOne = 71;
  static const int _eighty = 80;
  static const int _hundred = 100;
  static const int _thousand = 1000;

  static const List<String> _units = <String>[
    'zéro',
    'un',
    'deux',
    'trois',
    'quatre',
    'cinq',
    'six',
    'sept',
    'huit',
    'neuf',
    'dix',
    'onze',
    'douze',
    'treize',
    'quatorze',
    'quinze',
    'seize',
  ];
  static const Map<int, String> _tens = <int, String>{
    20: 'vingt',
    30: 'trente',
    40: 'quarante',
    50: 'cinquante',
    60: 'soixante',
  };

  /// Returns [number], from 0 to [maxNumber], in words.
  static String spell(int number) {
    assert(number >= 0 && number <= maxNumber, 'Out of range: $number');
    final int thousands = number ~/ _thousand;
    final int rest = number % _thousand;
    if (thousands == 0) return _belowThousand(rest, isLast: true);
    final String thousandWords = thousands == 1
        ? 'mille'
        : '${_belowThousand(thousands, isLast: false)} mille';
    if (rest == 0) return thousandWords;
    return '$thousandWords ${_belowThousand(rest, isLast: true)}';
  }

  /// "cent" and "quatre-vingt" take an s only when they end the number.
  static String _belowThousand(int number, {required bool isLast}) {
    final int hundreds = number ~/ _hundred;
    final int rest = number % _hundred;
    if (hundreds == 0) return _belowHundred(rest, isLast: isLast);
    final String hundredWords = hundreds == 1
        ? 'cent'
        : '${_units[hundreds]} cent';
    if (rest == 0) {
      return hundreds > 1 && isLast ? '${hundredWords}s' : hundredWords;
    }
    return '$hundredWords ${_belowHundred(rest, isLast: isLast)}';
  }

  static String _belowHundred(int number, {required bool isLast}) {
    if (number < _seventeen) return _units[number];
    if (number < _twenty) return 'dix-${_units[number - _ten]}';
    if (number < _seventy) return _regularTens(number);
    if (number == _seventyOne) return 'soixante et onze';
    if (number < _eighty) {
      return 'soixante-${_belowHundred(number - _sixty, isLast: isLast)}';
    }
    if (number == _eighty) return isLast ? 'quatre-vingts' : 'quatre-vingt';
    return 'quatre-vingt-${_belowHundred(number - _eighty, isLast: isLast)}';
  }

  static String _regularTens(int number) {
    final String tens = _tens[number - number % _ten]!;
    return switch (number % _ten) {
      0 => tens,
      1 => '$tens et un',
      final int unit => '$tens-${_units[unit]}',
    };
  }
}
