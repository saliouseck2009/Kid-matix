/// Operator shown in a question prompt.
enum MathOperator {
  /// Multiplication, shown as "×".
  multiply,

  /// Addition, shown as "+": `30 + 4 = 34` tells the tens and the ones of
  /// a number (version 2.0).
  add,

  /// "Is smaller than", shown as "<" (version 2.0).
  lessThan,

  /// "Is greater than", shown as ">" (version 2.0).
  greaterThan,

  /// "Is equal to", shown as "=" between two numbers compared, such as
  /// `15 = 15`; an operation's result follows the equals token instead
  /// (version 2.0).
  equalTo,
}
