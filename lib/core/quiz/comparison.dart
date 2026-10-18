/// How a first number compares with a second one.
enum Comparison {
  /// The first number is smaller: `34 < 43`.
  less,

  /// Both numbers are equal: `15 = 15`.
  equal,

  /// The first number is greater: `58 > 49`.
  greater;

  /// How [first] compares with [second].
  static Comparison of(int first, int second) {
    if (first < second) return Comparison.less;
    if (first > second) return Comparison.greater;
    return Comparison.equal;
  }
}
