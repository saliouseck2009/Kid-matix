import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:meta/meta.dart';

/// Where a QR code of results stands, shown or read.
@immutable
sealed class ResultsQrState {
  const ResultsQrState();
}

/// The code is being made, or the code read is being merged.
final class ResultsQrBusy extends ResultsQrState {
  /// Creates the state.
  const ResultsQrBusy();
}

/// The camera waits for a code.
final class ResultsQrScanning extends ResultsQrState {
  /// Creates the state.
  const ResultsQrScanning();
}

/// The code is shown.
final class ResultsQrShown extends ResultsQrState {
  /// Creates the state.
  const ResultsQrShown({
    required this.text,
    required this.sequence,
    required this.sessionCount,
  });

  /// Text of the code.
  final String text;

  /// Local sequence the code reaches.
  final int sequence;

  /// Sessions it carries.
  final int sessionCount;
}

/// The teacher's tablet read the code; this tablet remembered it.
final class ResultsQrSent extends ResultsQrState {
  /// Creates the state.
  const ResultsQrSent();
}

/// The code read was merged.
final class ResultsQrMerged extends ResultsQrState {
  /// Creates the state.
  const ResultsQrMerged({required this.report});

  /// What it added.
  final ClassroomMergeReport report;
}

/// No code can be made, or the code read could not be merged.
final class ResultsQrFailed extends ResultsQrState {
  /// Creates the state.
  const ResultsQrFailed({required this.errorCode});

  /// Why: `validation` when there is nothing new, `limitReached` when the
  /// file is needed, `notFound` when the class is not on this tablet.
  final AppErrorCode errorCode;
}
