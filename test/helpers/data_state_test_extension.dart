import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';

/// Shortcuts to read a [DataState] in tests.
extension DataStateTestExtension<T> on DataState<T> {
  /// The data of a success; fails the test on a failure.
  T get requireData => switch (this) {
    DataSuccess<T>(:final T data) => data,
    DataFailed<T>(:final AppException exception) => throw StateError(
      'Expected a success, got $exception',
    ),
  };

  /// The exception of a failure, or `null` on a success.
  AppException? get exceptionOrNull => switch (this) {
    DataSuccess<T>() => null,
    DataFailed<T>(:final AppException exception) => exception,
  };
}
