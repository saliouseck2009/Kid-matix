import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessments_overview.dart';
import 'package:meta/meta.dart';

/// Where the page of the assessments of a class stands.
@immutable
sealed class ClassAssessmentsState {
  const ClassAssessmentsState();
}

/// The assessments are being read.
final class ClassAssessmentsLoading extends ClassAssessmentsState {
  /// Creates the state.
  const ClassAssessmentsLoading();
}

/// The assessments are shown.
final class ClassAssessmentsLoaded extends ClassAssessmentsState {
  /// Creates the state; [failure] when the last change failed.
  const ClassAssessmentsLoaded({required this.overview, this.failure});

  /// What the page shows.
  final ClassAssessmentsOverview overview;

  /// Why the last opening or closing failed, or `null`.
  final AppErrorCode? failure;
}

/// The assessments could not be read.
final class ClassAssessmentsFailure extends ClassAssessmentsState {
  /// Creates the state.
  const ClassAssessmentsFailure({required this.errorCode});

  /// Why.
  final AppErrorCode errorCode;
}
