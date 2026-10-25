import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';

/// Makes the anonymous version of a report: each pupil is their number in
/// the class list, and nothing else of them is kept (owner, 2026-10-25:
/// every report also exists without nicknames).
///
/// A report holds no other personal data: no identifier, no avatar, no
/// date of birth; the class keeps the name its teacher gave it.
abstract final class ReportAnonymizer {
  /// The anonymous version of [report].
  static ClassProgressReport anonymize(ClassProgressReport report) {
    return ClassProgressReport(
      classroomName: report.classroomName,
      from: report.from,
      to: report.to,
      generatedAt: report.generatedAt,
      domains: report.domains,
      wordsFrom: report.wordsFrom,
      wordsTo: report.wordsTo,
      practiceTime: report.practiceTime,
      sessionCount: report.sessionCount,
      acquiredItemCount: report.acquiredItemCount,
      pupils: report.pupils.map(_anonymousRowOf).toList(),
      isAnonymous: true,
    );
  }

  static PupilReportRow _anonymousRowOf(PupilReportRow row) {
    return PupilReportRow(
      number: row.number,
      levelsFrom: row.levelsFrom,
      levelsTo: row.levelsTo,
      wordsFrom: row.wordsFrom,
      wordsTo: row.wordsTo,
      practiceTime: row.practiceTime,
      sessionCount: row.sessionCount,
      acquiredItemCount: row.acquiredItemCount,
    );
  }
}
