/// Source of the current date and time.
///
/// Injected everywhere a date matters (streaks, spaced repetition) so tests
/// can control time.
abstract interface class Clock {
  /// Returns the current local date and time.
  DateTime now();
}
