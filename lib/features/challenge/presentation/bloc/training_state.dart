import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:meta/meta.dart';

/// What the training screen shows.
@immutable
sealed class TrainingState {
  const TrainingState();
}

/// The last choice is being read.
final class TrainingLoading extends TrainingState {
  /// Creates the state.
  const TrainingLoading();
}

/// The training the child is choosing.
final class TrainingReady extends TrainingState {
  /// Creates the state.
  const TrainingReady({required this.choice});

  /// Tables, question count and timer chosen so far.
  final TrainingSource choice;

  /// Whether the training can start: at least one table is chosen.
  bool get canLaunch => choice.unitKeys.isNotEmpty;
}

/// The choice could not be read.
final class TrainingFailure extends TrainingState {
  /// Creates the state.
  const TrainingFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
