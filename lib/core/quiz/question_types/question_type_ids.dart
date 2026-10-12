/// Identifiers of the question types.
abstract final class QuestionTypeIds {
  /// Pick the result among four numbers: `7 × 8 = ?`.
  static const String multipleChoice = 'multipleChoice';

  /// Write the result on the keypad: `6 × 9 = ?`.
  static const String typedAnswer = 'typedAnswer';

  /// Write the missing number: `7 × ? = 56`.
  static const String missingNumber = 'missingNumber';

  /// Say whether a statement is true: `6 × 7 = 48`.
  static const String trueFalse = 'trueFalse';

  /// Pick the operation that gives a result: `? = 24`, version 1.1.
  static const String findOperation = 'findOperation';

  /// Match 4 operations with their 4 results, version 1.1.
  static const String matchPairs = 'matchPairs';
}
