/// Time to answer one question, before the player's timer mode applies.
abstract final class QuizTimeLimits {
  /// Normal timer of free training (owner's choice).
  static const Duration freeTraining = Duration(seconds: 10);

  /// The relaxed timer multiplies the time by 1.5: 3 halves.
  static const int relaxedNumerator = 3;

  /// Denominator of the relaxed factor.
  static const int relaxedDenominator = 2;

  /// The timer turns to its warning color in the last 3 seconds.
  static const Duration warning = Duration(seconds: 3);
}
