import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:meta/meta.dart';

/// What happened to the last export of a report.
enum ReportExportOutcome {
  /// The files went to the share sheet.
  shared,

  /// The files could not be made or shared.
  failed,
}

/// The choices of the report card of a class and its last export.
@immutable
final class ClassReportState {
  /// Creates the state.
  const ClassReportState({
    required this.toKey,
    this.fromKey,
    this.isBusy = false,
    this.outcome,
    this.errorCode,
  });

  /// Key of the first period compared, or `null` for one period.
  final String? fromKey;

  /// Key of the second period compared.
  final String toKey;

  /// Whether files are being made or shared.
  final bool isBusy;

  /// What the last export gave, or `null` before any.
  final ReportExportOutcome? outcome;

  /// Why the last export failed, or `null`.
  final AppErrorCode? errorCode;

  /// Returns a copy with new periods and no outcome.
  ClassReportState withPeriods({
    required String? fromKey,
    required String toKey,
  }) {
    return ClassReportState(fromKey: fromKey, toKey: toKey);
  }

  /// Returns a copy while files are made.
  ClassReportState get busy =>
      ClassReportState(fromKey: fromKey, toKey: toKey, isBusy: true);

  /// Returns a copy after an export.
  ClassReportState done(ReportExportOutcome outcome, {AppErrorCode? code}) {
    return ClassReportState(
      fromKey: fromKey,
      toKey: toKey,
      outcome: outcome,
      errorCode: code,
    );
  }
}
