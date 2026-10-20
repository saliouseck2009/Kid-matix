import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:meta/meta.dart';

/// What the door of the teacher area asks for.
enum TeacherCodeStep {
  /// The code exists: type it to open the area.
  enter,

  /// First visit: choose a code.
  choose,

  /// First visit: type the chosen code again.
  confirm,
}

/// Why the last code typed was refused.
enum TeacherCodeError {
  /// Not 4 digits.
  invalid,

  /// Not the code of the device.
  wrong,

  /// The second code typed at the first visit differs from the first.
  mismatch,
}

/// What the door of the teacher area shows.
@immutable
sealed class TeacherAccessState {
  const TeacherAccessState();
}

/// The door is reading whether a code exists.
final class TeacherAccessLoading extends TeacherAccessState {
  /// Creates the state.
  const TeacherAccessLoading();
}

/// The door waits for a code.
final class TeacherAccessReady extends TeacherAccessState {
  /// Creates the state at [step].
  const TeacherAccessReady({
    required this.step,
    this.chosenCode,
    this.error,
    this.isBusy = false,
  });

  /// What is asked.
  final TeacherCodeStep step;

  /// The code chosen at the first step of the first visit, to confirm.
  final String? chosenCode;

  /// Why the last code was refused, or `null`.
  final TeacherCodeError? error;

  /// Whether a code is being checked or saved.
  final bool isBusy;
}

/// The door could not read or save the code.
final class TeacherAccessFailure extends TeacherAccessState {
  /// Creates the state.
  const TeacherAccessFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
