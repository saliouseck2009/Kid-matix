/// Source of randomness.
///
/// Injected wherever questions are drawn or shuffled so a seed makes the
/// outcome reproducible.
abstract interface class RandomSource {
  /// Returns a random integer from 0 inclusive to [max] exclusive.
  int nextInt(int max);

  /// Returns a shuffled copy of [items]; [items] itself is left untouched.
  List<T> shuffled<T>(List<T> items);
}
