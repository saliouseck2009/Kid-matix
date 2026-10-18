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
}
