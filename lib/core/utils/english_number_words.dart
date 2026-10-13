/// Writes a whole number in English words, the American way: 347 is
/// "three hundred forty-seven", 2000 "two thousand", 1015 "one thousand
/// fifteen".
///
/// The parental gate shows a number this way to an English interface.
abstract final class EnglishNumberWords {
  /// Largest number spelled.
  static const int maxNumber = 999999;

  static const int _ten = 10;
  static const int _twenty = 20;
  static const int _hundred = 100;
  static const int _thousand = 1000;

  static const List<String> _units = <String>[
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen',
  ];
  static const Map<int, String> _tens = <int, String>{
    20: 'twenty',
    30: 'thirty',
    40: 'forty',
    50: 'fifty',
    60: 'sixty',
    70: 'seventy',
    80: 'eighty',
    90: 'ninety',
  };

  /// Returns [number], from 0 to [maxNumber], in words.
  static String spell(int number) {
    assert(number >= 0 && number <= maxNumber, 'Out of range: $number');
    final int thousands = number ~/ _thousand;
    final int rest = number % _thousand;
    if (thousands == 0) return _belowThousand(rest);
    final String thousandWords = '${_belowThousand(thousands)} thousand';
    if (rest == 0) return thousandWords;
    return '$thousandWords ${_belowThousand(rest)}';
  }

  static String _belowThousand(int number) {
    final int hundreds = number ~/ _hundred;
    final int rest = number % _hundred;
    if (hundreds == 0) return _belowHundred(rest);
    final String hundredWords = '${_units[hundreds]} hundred';
    if (rest == 0) return hundredWords;
    return '$hundredWords ${_belowHundred(rest)}';
  }

  static String _belowHundred(int number) {
    if (number < _twenty) return _units[number];
    final String tens = _tens[number - number % _ten]!;
    final int unit = number % _ten;
    return unit == 0 ? tens : '$tens-${_units[unit]}';
  }
}
