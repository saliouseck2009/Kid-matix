import 'package:kid_matix/features/classroom/domain/entities/domain_progress.dart';
import 'package:meta/meta.dart';

/// One class, or all of them, in a school or program report: figures
/// only, never a pupil.
@immutable
final class ProgramReportRow {
  /// Creates the row of [name]; `null` for the total of every class.
  ProgramReportRow({
    required this.pupilCount,
    required this.assessedFromCount,
    required this.assessedToCount,
    required List<DomainProgress> domains,
    required this.practiceTime,
    required this.sessionCount,
    required this.acquiredItemCount,
    this.name,
    this.wordsFrom,
    this.wordsTo,
    this.isSecondPeriodOnly = false,
  }) : domains = List<DomainProgress>.unmodifiable(domains);

  /// Name of the class, or `null` for the total.
  final String? name;

  /// Whether the class has no assessment of the first period and is
  /// reported on the second alone.
  final bool isSecondPeriodOnly;

  /// Pupils of the class.
  final int pupilCount;

  /// Pupils who took the first assessment.
  final int assessedFromCount;

  /// Pupils who took the second assessment.
  final int assessedToCount;

  /// Each domain of the placement test.
  final List<DomainProgress> domains;

  /// Average share of the words understood at the first assessment.
  final double? wordsFrom;

  /// Average share of the words understood at the second assessment.
  final double? wordsTo;

  /// Time played between the two assessments.
  final Duration practiceTime;

  /// Sessions played between the two assessments.
  final int sessionCount;

  /// Facts and words acquired between the two assessments.
  final int acquiredItemCount;

  /// The progress in [domainId], or `null` when nobody was assessed in it.
  DomainProgress? domainOf(String domainId) {
    for (final DomainProgress domain in domains) {
      if (domain.domainId == domainId) return domain;
    }
    return null;
  }
}

/// The report of a school or a program: the classes merged on the
/// coordinator's device, compared between two periods, anonymous only.
@immutable
final class ProgramReport {
  /// Creates the report.
  ProgramReport({
    required this.toLabel,
    required this.generatedAt,
    required List<ProgramReportRow> classes,
    required this.total,
    required List<String> domainIds,
    this.fromLabel,
  }) : classes = List<ProgramReportRow>.unmodifiable(classes),
       domainIds = List<String>.unmodifiable(domainIds);

  /// Label of the first period, or `null` for one period.
  final String? fromLabel;

  /// Label of the second period.
  final String toLabel;

  /// When the report was made.
  final DateTime generatedAt;

  /// Each class that has the second period.
  final List<ProgramReportRow> classes;

  /// Every class together.
  final ProgramReportRow total;

  /// The domains of the report, in the order of the placement test.
  final List<String> domainIds;
}
