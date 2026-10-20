import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_summary.dart';
import 'package:meta/meta.dart';

/// What a list of classes shows.
@immutable
sealed class ClassroomsState {
  const ClassroomsState();
}

/// The classes are being read.
final class ClassroomsLoading extends ClassroomsState {
  /// Creates the state.
  const ClassroomsLoading();
}

/// The classes of the device, oldest first.
final class ClassroomsLoaded extends ClassroomsState {
  /// Creates the state.
  const ClassroomsLoaded({required this.classrooms, this.codeChangedAt});

  /// Every class with its number of pupils.
  final List<ClassroomSummary> classrooms;

  /// When the teacher code was replaced after « Code oublié ? », or
  /// `null`.
  final DateTime? codeChangedAt;
}

/// The classes could not be read.
final class ClassroomsFailure extends ClassroomsState {
  /// Creates the state.
  const ClassroomsFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
