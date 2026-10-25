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

  /// Count the objects drawn and pick their number among four, version
  /// 2.0.
  static const String countObjects = 'countObjects';

  /// Read the bundles of ten and the loose sticks drawn and pick their
  /// number among four, version 2.0.
  static const String tensAndOnes = 'tensAndOnes';

  /// Say whether a number is smaller than, equal to or greater than
  /// another with one of three signs: `34 ? 43`, version 2.0.
  static const String compare = 'compare';

  /// Find the number missing on a number line among four, version 2.0.
  static const String numberLine = 'numberLine';

  /// Hear a math word and touch its drawing among four, version 2.0.
  static const String listenAndTouch = 'listenAndTouch';

  /// Match four expressions with their drawings, version 2.0.
  static const String wordAndImage = 'wordAndImage';

  /// Touch the math words of a sentence to hear and see them, version 2.0.
  static const String touchToUnderstand = 'touchToUnderstand';

  /// Pick +, −, × or ÷ for a short statement, version 2.0.
  static const String whichOperation = 'whichOperation';

  /// Solve a word problem step by step: listen, draw the bar model, pick
  /// the operation, compute, check, version 2.0.
  static const String solveProblem = 'solveProblem';

  /// Fill the bar model of a word problem, pick the operation, then
  /// compute, version 2.0.
  static const String barModel = 'barModel';

  /// Pick +, −, × or ÷ for a word problem, version 2.0.
  static const String problemOperation = 'problemOperation';
}
