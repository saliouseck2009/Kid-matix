import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/domain_progress.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';
import 'package:meta/meta.dart';

/// The progress report of a class between two assessment periods: per
/// domain of the placement test, the words understood, the practice and
/// the facts acquired, for the class and for each pupil.
@immutable
final class ClassProgressReport {
  /// Creates the report of [classroomName].
  ClassProgressReport({
    required this.classroomName,
    required this.to,
    required this.generatedAt,
    required List<DomainProgress> domains,
    required List<PupilReportRow> pupils,
    required this.practiceTime,
    required this.sessionCount,
    required this.acquiredItemCount,
    this.from,
    this.wordsFrom,
    this.wordsTo,
    this.isAnonymous = false,
  }) : domains = List<DomainProgress>.unmodifiable(domains),
       pupils = List<PupilReportRow>.unmodifiable(pupils);

  /// Name of the class.
  final String classroomName;

  /// The first period compared, or `null` for a report of one period.
  final AssessmentPeriod? from;

  /// The second period compared.
  final AssessmentPeriod to;

  /// When the report was made.
  final DateTime generatedAt;

  /// Each domain of the placement test some pupil was assessed in.
  final List<DomainProgress> domains;

  /// Average share of the words understood at the first period, or
  /// `null` when nobody took it.
  final double? wordsFrom;

  /// Average share of the words understood at the second period.
  final double? wordsTo;

  /// Time the class played between the two periods.
  final Duration practiceTime;

  /// Sessions the class played between the two periods.
  final int sessionCount;

  /// Facts and words acquired by the class between the two periods.
  final int acquiredItemCount;

  /// Each pupil, in the order of the class list.
  final List<PupilReportRow> pupils;

  /// Whether the pupils are numbers only.
  final bool isAnonymous;

  @override
  String toString() => 'ClassProgressReport($classroomName, ${to.label})';
}
