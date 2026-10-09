/// Receives every uncaught error of the app.
///
/// Version 1.0 has no network, so the registered implementation only logs
/// locally. A remote service can replace it once online mode exists.
abstract interface class CrashReporter {
  /// Records an uncaught [error] with its [stackTrace].
  void recordError(Object error, StackTrace stackTrace);
}
