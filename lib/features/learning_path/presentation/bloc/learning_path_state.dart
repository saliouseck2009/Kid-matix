import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:meta/meta.dart';

/// What the learning path screens show.
@immutable
sealed class LearningPathState {
  const LearningPathState();
}

/// The path is being read.
final class LearningPathLoading extends LearningPathState {
  /// Creates the state.
  const LearningPathLoading();
}

/// The path of the player.
final class LearningPathLoaded extends LearningPathState {
  /// Creates the state.
  const LearningPathLoaded({required this.path});

  /// Tables, stages and stars.
  final LearningPathEntity path;
}

/// The path could not be read.
final class LearningPathFailure extends LearningPathState {
  /// Creates the state.
  const LearningPathFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
