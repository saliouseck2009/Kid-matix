/// Identifiers of the question types of version 1.0.
abstract final class QuestionTypeIds {
  /// Pick the result among four numbers: `7 × 8 = ?`.
  static const String multipleChoice = 'multipleChoice';

  /// Write the result on the keypad: `6 × 9 = ?`.
  static const String typedAnswer = 'typedAnswer';

  /// Write the missing number: `7 × ? = 56`.
  static const String missingNumber = 'missingNumber';

  /// Say whether a statement is true: `6 × 7 = 48`.
  static const String trueFalse = 'trueFalse';
}
