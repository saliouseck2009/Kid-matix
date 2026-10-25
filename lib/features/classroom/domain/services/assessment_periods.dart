import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_rules.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';

/// Groups the assessments of a class into periods and reads the result
/// of each pupil in a period.
abstract final class AssessmentPeriods {
  /// The periods of [assessments], the earliest first.
  static List<AssessmentPeriod> of(Iterable<ClassAssessment> assessments) {
    final List<ClassAssessment> ordered = assessments.toList()
      ..sort(_byOpening);
    final Map<String, List<ClassAssessment>> byKey =
        <String, List<ClassAssessment>>{};
    for (final ClassAssessment assessment in ordered) {
      byKey
          .putIfAbsent(
            AssessmentRules.periodKeyOf(assessment.periodLabel),
            () => <ClassAssessment>[],
          )
          .add(assessment);
    }
    return <AssessmentPeriod>[
      for (final MapEntry<String, List<ClassAssessment>> entry in byKey.entries)
        AssessmentPeriod(
          key: entry.key,
          label: entry.value.first.periodLabel,
          startedAt: entry.value.first.openedAt,
          assessmentIds: entry.value
              .map((ClassAssessment assessment) => assessment.id)
              .toList(),
        ),
    ];
  }

  /// The result of each pupil in [period], by pupil identifier: their
  /// latest one when they took two assessments of the period.
  static Map<String, AssessmentResult> resultsIn(
    AssessmentPeriod? period,
    Iterable<AssessmentResult> results,
  ) {
    if (period == null) return const <String, AssessmentResult>{};
    final Set<String> ids = period.assessmentIds.toSet();
    final Map<String, AssessmentResult> byPupil = <String, AssessmentResult>{};
    for (final AssessmentResult result in results) {
      if (!ids.contains(result.assessmentId)) continue;
      final AssessmentResult? kept = byPupil[result.pupilId];
      if (kept == null || result.takenAt.isAfter(kept.takenAt)) {
        byPupil[result.pupilId] = result;
      }
    }
    return byPupil;
  }

  /// The period of [periods] whose key is [key], or `null`.
  static AssessmentPeriod? find(List<AssessmentPeriod> periods, String? key) {
    for (final AssessmentPeriod period in periods) {
      if (period.key == key) return period;
    }
    return null;
  }

  static int _byOpening(ClassAssessment a, ClassAssessment b) {
    final int byDate = a.openedAt.compareTo(b.openedAt);
    return byDate != 0 ? byDate : a.id.compareTo(b.id);
  }
}
