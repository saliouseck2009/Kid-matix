import 'dart:developer';

import 'package:kid_matix/core/services/crash_reporter.dart';

/// [CrashReporter] that writes errors to the developer log only.
final class LogCrashReporter implements CrashReporter {
  /// Creates a reporter that never leaves the device.
  const LogCrashReporter();

  static const String _logName = 'crash';

  @override
  void recordError(Object error, StackTrace stackTrace) {
    log(
      'Uncaught error',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
