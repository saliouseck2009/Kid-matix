import 'package:kid_matix/core/error/app_exception.dart';

/// Result of a repository call: either [DataSuccess] or [DataFailed].
///
/// The type is sealed, so a `switch` over it is checked for exhaustiveness.
sealed class DataState<T> {
  /// Creates a repository result.
  const DataState();
}

/// The call succeeded and produced [data].
final class DataSuccess<T> extends DataState<T> {
  /// Wraps the produced [data].
  const DataSuccess(this.data);

  /// Value produced by the call.
  final T data;
}

/// The call failed with a typed [exception].
final class DataFailed<T> extends DataState<T> {
  /// Wraps the [exception] that explains the failure.
  const DataFailed(this.exception);

  /// Typed reason of the failure.
  final AppException exception;
}
