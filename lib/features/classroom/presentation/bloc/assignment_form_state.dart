import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:meta/meta.dart';

/// When an assignment is due.
enum AssignmentDue {
  /// No date.
  none,

  /// Tomorrow.
  tomorrow,

  /// In a week.
  nextWeek,
}

/// The choice of the unit to give a class.
@immutable
final class AssignmentFormState {
  /// Creates the state.
  const AssignmentFormState({
    required this.domainId,
    this.due = AssignmentDue.none,
    this.isSaving = false,
    this.isGiven = false,
    this.errorCode,
  });

  /// Domain whose units are listed.
  final String domainId;

  /// When the assignment is due.
  final AssignmentDue due;

  /// Whether the assignment is being saved.
  final bool isSaving;

  /// Whether it was given; the page then goes back.
  final bool isGiven;

  /// Why it could not be given, or `null`.
  final AppErrorCode? errorCode;

  /// Returns a copy with the given fields replaced, without error.
  AssignmentFormState copyWith({
    String? domainId,
    AssignmentDue? due,
    bool? isSaving,
    bool? isGiven,
    AppErrorCode? errorCode,
  }) {
    return AssignmentFormState(
      domainId: domainId ?? this.domainId,
      due: due ?? this.due,
      isSaving: isSaving ?? false,
      isGiven: isGiven ?? false,
      errorCode: errorCode,
    );
  }
}
