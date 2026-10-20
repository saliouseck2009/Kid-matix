import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_overview.dart';
import 'package:meta/meta.dart';

/// What the page of a class shows.
@immutable
sealed class ClassOverviewState {
  const ClassOverviewState();
}

/// The class is being read.
final class ClassOverviewLoading extends ClassOverviewState {
  /// Creates the state.
  const ClassOverviewLoading();
}

/// The class, its assignment, dashboard, groups and challenge.
final class ClassOverviewLoaded extends ClassOverviewState {
  /// Creates the state.
  const ClassOverviewLoaded({required this.overview, this.errorCode});

  /// Everything the page shows.
  final ClassOverview overview;

  /// Why the last change failed, shown once, or `null`.
  final AppErrorCode? errorCode;
}

/// The class could not be read.
final class ClassOverviewFailure extends ClassOverviewState {
  /// Creates the state.
  const ClassOverviewFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
