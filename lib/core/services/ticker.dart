/// Source of regular ticks that drives the quiz timers.
///
/// Timers live in Blocs and listen to this interface, so tests can replace
/// real time with a controlled stream.
abstract interface class Ticker {
  /// Emits 1, 2, 3... once per [interval] until the listener cancels.
  Stream<int> tick({required Duration interval});
}
