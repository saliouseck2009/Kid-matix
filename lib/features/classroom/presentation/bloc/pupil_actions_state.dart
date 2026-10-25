import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:meta/meta.dart';

/// What the teacher did to a pupil.
enum PupilActionKind {
  /// Their progress was erased.
  reset,

  /// They were removed from the class.
  remove,
}

/// The outcome of the last action of the teacher on a pupil.
@immutable
sealed class PupilActionsState {
  const PupilActionsState();
}

/// No action yet.
final class PupilActionsIdle extends PupilActionsState {
  /// Creates the state.
  const PupilActionsIdle();
}

/// An action succeeded; each one is a new object, so two in a row are
/// both told.
final class PupilActionDone extends PupilActionsState {
  /// Creates the state.
  const PupilActionDone({required this.kind, required this.nickname});

  /// What was done.
  final PupilActionKind kind;

  /// To whom.
  final String nickname;
}

/// An action failed.
final class PupilActionFailed extends PupilActionsState {
  /// Creates the state.
  const PupilActionFailed({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
