import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/services/crash_reporter.dart';

/// Observes every Bloc and Cubit of the app.
///
/// Errors always reach the [CrashReporter]; state changes are logged in
/// debug builds only.
final class AppBlocObserver extends BlocObserver {
  /// Creates an observer that forwards errors to [crashReporter].
  const AppBlocObserver({required this._crashReporter});

  static const String _logName = 'bloc';

  final CrashReporter _crashReporter;

  @override
  void onChange(BlocBase<Object?> bloc, Change<Object?> change) {
    super.onChange(bloc, change);
    if (kDebugMode) log('${bloc.runtimeType} $change', name: _logName);
  }

  @override
  void onError(BlocBase<Object?> bloc, Object error, StackTrace stackTrace) {
    _crashReporter.recordError(error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
