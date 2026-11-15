import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_progress_entity.dart';
import 'package:meta/meta.dart';

/// What « Mes parcours » shows.
@immutable
sealed class PathOverviewState {
  const PathOverviewState();
}

/// The progress in every domain is being read.
final class PathOverviewLoading extends PathOverviewState {
  /// Creates the state.
  const PathOverviewLoading();
}

/// The progress in every domain.
final class PathOverviewLoaded extends PathOverviewState {
  /// Creates the state of [overview].
  const PathOverviewLoaded({required this.overview});

  /// Domains, their progress and the one recommended.
  final PathOverviewEntity overview;
}

/// The progress could not be read.
final class PathOverviewFailure extends PathOverviewState {
  /// Creates the state for [errorCode].
  const PathOverviewFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
