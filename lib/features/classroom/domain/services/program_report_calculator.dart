import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/domain_progress.dart';
import 'package:kid_matix/features/classroom/domain/entities/program_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';
import 'package:kid_matix/features/classroom/domain/services/class_progress_calculator.dart';

/// Consolidates the reports of several classes into the report of a
/// school or a program: one row per class and a total computed over every
/// pupil of every class (not an average of the classes), with no pupil
/// in it.
abstract final class ProgramReportCalculator {
  /// The report of [classes], each compared between the same periods.
  static ProgramReport compute({
    required List<ClassProgressReport> classes,
    required String? fromLabel,
    required String toLabel,
    required DateTime generatedAt,
  }) {
    final List<PupilReportRow> everyPupil = <PupilReportRow>[
      for (final ClassProgressReport report in classes) ...report.pupils,
    ];
    return ProgramReport(
      fromLabel: fromLabel,
      toLabel: toLabel,
      generatedAt: generatedAt,
      classes: <ProgramReportRow>[
        for (final ClassProgressReport report in classes)
          rowOf(report.pupils, name: report.classroomName),
      ],
      total: rowOf(everyPupil),
      domainIds: <String>{
        for (final ClassProgressReport report in classes)
          for (final DomainProgress domain in report.domains) domain.domainId,
      }.toList(),
    );
  }

  /// The row of [pupils], those of the class [name] or of every class.
  static ProgramReportRow rowOf(List<PupilReportRow> pupils, {String? name}) {
    final Set<String> domainIds = <String>{
      for (final PupilReportRow row in pupils) ...<String>[
        ...row.levelsFrom.keys,
        ...row.levelsTo.keys,
      ],
    };
    return ProgramReportRow(
      name: name,
      pupilCount: pupils.length,
      assessedFromCount: pupils.where(_wasAssessedFrom).length,
      assessedToCount: pupils.where(_wasAssessedTo).length,
      domains: <DomainProgress>[
        for (final String domainId in domainIds)
          ClassProgressCalculator.progressIn(domainId, pupils),
      ],
      wordsFrom: ClassProgressCalculator.averageOf(
        pupils.map((PupilReportRow row) => _shareOf(row.wordsFrom)),
      ),
      wordsTo: ClassProgressCalculator.averageOf(
        pupils.map((PupilReportRow row) => _shareOf(row.wordsTo)),
      ),
      practiceTime: pupils.fold(
        Duration.zero,
        (Duration total, PupilReportRow row) => total + row.practiceTime,
      ),
      sessionCount: pupils.fold(
        0,
        (int total, PupilReportRow row) => total + row.sessionCount,
      ),
      acquiredItemCount: pupils.fold(
        0,
        (int total, PupilReportRow row) => total + row.acquiredItemCount,
      ),
    );
  }

  static bool _wasAssessedFrom(PupilReportRow row) =>
      row.levelsFrom.isNotEmpty || row.wordsFrom != null;

  static bool _wasAssessedTo(PupilReportRow row) =>
      row.levelsTo.isNotEmpty || row.wordsTo != null;

  static double? _shareOf(WordScore? score) {
    if (score == null || score.asked == 0) return null;
    return score.understood / score.asked;
  }
}
