import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';

/// What the results screen shows.
sealed class ResultsState {
  /// Creates a state.
  const ResultsState();
}

/// The session is loading.
final class ResultsLoading extends ResultsState {
  /// Creates the state.
  const ResultsLoading();
}

/// The results are ready.
final class ResultsLoaded extends ResultsState {
  /// Creates the state.
  const ResultsLoaded({required this.result});

  /// Saved session and its answers.
  final QuizResultEntity result;
}

/// The session could not be read.
final class ResultsFailure extends ResultsState {
  /// Creates the state.
  const ResultsFailure({required this.errorCode});

  /// Reason of the failure.
  final AppErrorCode errorCode;
}
