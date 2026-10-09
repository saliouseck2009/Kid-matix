import 'package:kid_matix/core/services/clock.dart';

/// [Clock] backed by the device clock.
final class SystemClock implements Clock {
  /// Creates a clock that reads the device time.
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
