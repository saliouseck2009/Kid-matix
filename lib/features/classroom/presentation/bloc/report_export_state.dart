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
final class ReportExportState {
  /// Creates the state.
  const ReportExportState({
    required this.toKey,
    this.fromKey,
    this.isNamed = false,
    this.isBusy = false,
    this.outcome,
    this.errorCode,
  });

  /// Key of the first period compared, or `null` for one period.
  final String? fromKey;

  /// Key of the second period compared.
  final String toKey;

  /// Whether the next export is the named version, for the teacher only;
  /// the anonymous version, to share, by default. The two are never
  /// shared together.
  final bool isNamed;

  /// Whether files are being made or shared.
  final bool isBusy;

  /// What the last export gave, or `null` before any.
  final ReportExportOutcome? outcome;

  /// Why the last export failed, or `null`.
  final AppErrorCode? errorCode;

  /// Returns a copy with new periods and no outcome.
  ReportExportState withPeriods({
    required String? fromKey,
    required String toKey,
  }) {
    return ReportExportState(fromKey: fromKey, toKey: toKey, isNamed: isNamed);
  }

  /// Returns a copy exporting the named version when [isNamed].
  ReportExportState withVersion({required bool isNamed}) {
    return ReportExportState(fromKey: fromKey, toKey: toKey, isNamed: isNamed);
  }

  /// Returns a copy while files are made.
  ReportExportState get busy => ReportExportState(
    fromKey: fromKey,
    toKey: toKey,
    isNamed: isNamed,
    isBusy: true,
  );

  /// Returns a copy after an export, back on the anonymous version: the
  /// named one is chosen again for each export.
  ReportExportState done(ReportExportOutcome outcome, {AppErrorCode? code}) {
    return ReportExportState(
      fromKey: fromKey,
      toKey: toKey,
      outcome: outcome,
      errorCode: code,
    );
  }
}
