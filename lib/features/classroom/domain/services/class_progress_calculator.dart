import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_dashboard.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/domain_progress.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_progress.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';
import 'package:kid_matix/features/classroom/domain/services/assessment_periods.dart';
import 'package:kid_matix/features/classroom/domain/services/class_dashboard_calculator.dart';

/// What [ClassProgressCalculator.compute] reads: a class, its pupils, the
/// two periods compared, the results of its assessments and the
/// sessions of its pupils.
typedef ClassProgressInput = ({
  ClassroomEntity classroom,
  List<PupilEntity> pupils,
  AssessmentPeriod? from,
  AssessmentPeriod to,
  List<AssessmentResult> results,
  List<PracticeSession> sessions,
  DateTime generatedAt,
  Map<String, int> numbers,
});

/// Computes the progress report of a class between two periods from its
/// results alone, like the dashboard: the levels and words of each
/// assessment, and, through [ClassDashboardCalculator] run on the
/// sessions of each period, the practice between the two periods and the
/// items acquired during it.
///
/// Each pupil keeps the number of the class list stored at enrolment
/// (`numbers`), what the anonymous version shows.
///
/// The practice counts the sessions started from the opening of the
/// first period to the opening of the second; an item is acquired during
/// the period when it is acquired with the sessions before the second
/// opening and was not with those before the first.
abstract final class ClassProgressCalculator {
  /// The report of [input], pupils in the order of the class list.
  static ClassProgressReport compute(ClassProgressInput input) {
    final DateTime? start = input.from?.startedAt;
    final DateTime end = input.to.startedAt;
    final ClassDashboard practice = _dashboardOf(
      input,
      (PracticeSession s) =>
          (start == null || !s.startedAt.isBefore(start)) &&
          s.startedAt.isBefore(end),
    );
    final ClassDashboard before = _dashboardOf(
      input,
      (PracticeSession s) => start != null && s.startedAt.isBefore(start),
    );
    final ClassDashboard after = _dashboardOf(
      input,
      (PracticeSession s) => s.startedAt.isBefore(end),
    );
    final Map<String, AssessmentResult> fromResults =
        AssessmentPeriods.resultsIn(input.from, input.results);
    final Map<String, AssessmentResult> toResults = AssessmentPeriods.resultsIn(
      input.to,
      input.results,
    );
    final List<PupilReportRow> rows = <PupilReportRow>[
      for (int index = 0; index < input.pupils.length; index++)
        _rowOf(
          number: input.numbers[input.pupils[index].id] ?? index + 1,
          pupil: input.pupils[index],
          from: fromResults[input.pupils[index].id],
          to: toResults[input.pupils[index].id],
          practice: practice.pupils[index],
          acquired: after.pupils[index].acquiredItemKeys.difference(
            before.pupils[index].acquiredItemKeys,
          ),
        ),
    ];
    return _reportOf(input, rows);
  }

  static ClassProgressReport _reportOf(
    ClassProgressInput input,
    List<PupilReportRow> rows,
  ) {
    return ClassProgressReport(
      classroomName: input.classroom.name,
      from: input.from,
      to: input.to,
      generatedAt: input.generatedAt,
      domains: <DomainProgress>[
        for (final String domainId in _domainIdsOf(rows))
          progressIn(domainId, rows),
      ],
      wordsFrom: averageOf(
        rows.map((PupilReportRow r) => _shareOf(r.wordsFrom)),
      ),
      wordsTo: averageOf(rows.map((PupilReportRow r) => _shareOf(r.wordsTo))),
      practiceTime: rows.fold(
        Duration.zero,
        (Duration total, PupilReportRow row) => total + row.practiceTime,
      ),
      sessionCount: rows.fold(
        0,
        (int total, PupilReportRow row) => total + row.sessionCount,
      ),
      acquiredItemCount: rows.fold(
        0,
        (int total, PupilReportRow row) => total + row.acquiredItemCount,
      ),
      pupils: rows,
    );
  }

  /// How the pupils of [rows] moved in [domainId].
  static DomainProgress progressIn(String domainId, List<PupilReportRow> rows) {
    final List<double> starts = <double>[];
    final List<double> ends = <double>[];
    int progressed = 0;
    for (final PupilReportRow row in rows) {
      final double? start = row.levelsFrom[domainId]?.share;
      final double? end = row.levelsTo[domainId]?.share;
      if (start != null) starts.add(start);
      if (end != null) ends.add(end);
      if (start != null && end != null && end > start) progressed++;
    }
    return DomainProgress(
      domainId: domainId,
      averageFrom: averageOf(starts),
      averageTo: averageOf(ends),
      assessedFromCount: starts.length,
      assessedToCount: ends.length,
      progressedCount: progressed,
    );
  }

  /// The average of the values of [values] that are not `null`, or
  /// `null` when there is none.
  static double? averageOf(Iterable<double?> values) {
    final List<double> known = values.whereType<double>().toList();
    if (known.isEmpty) return null;
    return known.reduce((double a, double b) => a + b) / known.length;
  }

  static PupilReportRow _rowOf({
    required int number,
    required PupilEntity pupil,
    required AssessmentResult? from,
    required AssessmentResult? to,
    required PupilProgress practice,
    required Set<String> acquired,
  }) {
    return PupilReportRow(
      number: number,
      nickname: pupil.nickname,
      levelsFrom: _levelsOf(from),
      levelsTo: _levelsOf(to),
      wordsFrom: _wordsOf(from),
      wordsTo: _wordsOf(to),
      practiceTime: practice.practiceTime,
      sessionCount: practice.sessionCount,
      acquiredItemCount: acquired.length,
    );
  }

  static ClassDashboard _dashboardOf(
    ClassProgressInput input,
    bool Function(PracticeSession session) isIn,
  ) {
    return ClassDashboardCalculator.compute(
      pupils: input.pupils,
      sessions: input.sessions.where(isIn).toList(),
    );
  }

  static Map<String, DomainPlacement> _levelsOf(AssessmentResult? result) {
    return <String, DomainPlacement>{
      for (final DomainPlacement level
          in result?.levels ?? const <DomainPlacement>[])
        if (level.level != null) level.domainId: level,
    };
  }

  static WordScore? _wordsOf(AssessmentResult? result) {
    if (result == null || result.words.isEmpty) return null;
    return (understood: result.understoodWordCount, asked: result.words.length);
  }

  static double? _shareOf(WordScore? score) {
    if (score == null || score.asked == 0) return null;
    return score.understood / score.asked;
  }

  /// The domains of [rows], in the order they first appear.
  static List<String> _domainIdsOf(List<PupilReportRow> rows) {
    return <String>{
      for (final PupilReportRow row in rows) ...<String>[
        ...row.levelsFrom.keys,
        ...row.levelsTo.keys,
      ],
    }.toList();
  }
}
