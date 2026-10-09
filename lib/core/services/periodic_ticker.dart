import 'package:kid_matix/core/services/ticker.dart';

/// [Ticker] backed by a periodic stream.
final class PeriodicTicker implements Ticker {
  /// Creates a ticker driven by real time.
  const PeriodicTicker();

  @override
  Stream<int> tick({required Duration interval}) {
    return Stream<int>.periodic(interval, (int count) => count + 1);
  }
}
