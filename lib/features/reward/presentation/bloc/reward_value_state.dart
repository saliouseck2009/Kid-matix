import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:meta/meta.dart';

/// A reward value being read: the streak, the daily goal or the rewards
/// of a quiz.
@immutable
sealed class RewardValueState<T> {
  const RewardValueState();
}

/// The value is being read.
final class RewardValueLoading<T> extends RewardValueState<T> {
  /// Creates the state.
  const RewardValueLoading();
}

/// The value read.
final class RewardValueLoaded<T> extends RewardValueState<T> {
  /// Creates the state.
  const RewardValueLoaded({required this.value});

  /// Value read.
  final T value;
}

/// The value could not be read.
final class RewardValueFailure<T> extends RewardValueState<T> {
  /// Creates the state.
  const RewardValueFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
