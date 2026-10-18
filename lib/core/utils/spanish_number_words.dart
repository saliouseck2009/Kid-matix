/// Writes a whole number in Spanish words: 347 is "trescientos cuarenta
/// y siete", 100 "cien", 101 "ciento uno", 21000 "veintiún mil".
///
/// The parental gate shows a number this way to a Spanish interface.
abstract final class SpanishNumberWords {
  /// Largest number spelled.
  static const int maxNumber = 999999;

  static const int _ten = 10;
  static const int _thirty = 30;
  static const int _hundred = 100;
  static const int _thousand = 1000;

  static const List<String> _units = <String>[
    'cero',
    'uno',
    'dos',
    'tres',
    'cuatro',
    'cinco',
    'seis',
    'siete',
    'ocho',
    'nueve',
    'diez',
    'once',
    'doce',
    'trece',
    'catorce',
    'quince',
    'dieciséis',
    'diecisiete',
    'dieciocho',
    'diecinueve',
    'veinte',
    'veintiuno',
    'veintidós',
    'veintitrés',
    'veinticuatro',
    'veinticinco',
    'veintiséis',
    'veintisiete',
    'veintiocho',
    'veintinueve',
  ];
  static const Map<int, String> _tens = <int, String>{
    30: 'treinta',
    40: 'cuarenta',
    50: 'cincuenta',
    60: 'sesenta',
    70: 'setenta',
    80: 'ochenta',
    90: 'noventa',
  };
  static const List<String> _hundreds = <String>[
    '',
    'ciento',
    'doscientos',
    'trescientos',
    'cuatrocientos',
    'quinientos',
    'seiscientos',
    'setecientos',
    'ochocientos',
    'novecientos',
  ];

  /// Returns [number], from 0 to [maxNumber], in words.
  static String spell(int number) {
    assert(number >= 0 && number <= maxNumber, 'Out of range: $number');
    final int thousands = number ~/ _thousand;
    final int rest = number % _thousand;
    if (thousands == 0) return _belowThousand(rest);
    final String thousandWords = thousands == 1
        ? 'mil'
        : '${_beforeThousand(thousands)} mil';
    if (rest == 0) return thousandWords;
    return '$thousandWords ${_belowThousand(rest)}';
  }

  /// Before "mil", "uno" is shortened: "veintiún mil", "treinta y un
  /// mil", "ciento un mil".
  static String _beforeThousand(int number) {
    final String words = _belowThousand(number);
    if (words.endsWith('veintiuno')) {
      return '${words.substring(0, words.length - 'veintiuno'.length)}'
          'veintiún';
    }
    if (words.endsWith('uno')) return words.substring(0, words.length - 1);
    return words;
  }

  static String _belowThousand(int number) {
    final int hundreds = number ~/ _hundred;
    final int rest = number % _hundred;
    if (number == _hundred) return 'cien';
    if (hundreds == 0) return _belowHundred(rest);
    if (rest == 0) return _hundreds[hundreds];
    return '${_hundreds[hundreds]} ${_belowHundred(rest)}';
  }

  static String _belowHundred(int number) {
    if (number < _thirty) return _units[number];
    final String tens = _tens[number - number % _ten]!;
    final int unit = number % _ten;
    return unit == 0 ? tens : '$tens y ${_units[unit]}';
  }
}
