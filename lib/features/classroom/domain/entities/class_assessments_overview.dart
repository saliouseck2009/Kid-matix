import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:meta/meta.dart';

/// One assessment of a class and how many of its pupils took it.
typedef AssessmentStatus = ({ClassAssessment assessment, int takenCount});

/// What the page of the assessments of a class shows: each assessment
/// with how many pupils took it, and the periods the reports compare.
@immutable
final class ClassAssessmentsOverview {
  /// Creates the overview of [classroom].
  ClassAssessmentsOverview({
    required this.classroom,
    required this.pupilCount,
    required List<AssessmentStatus> assessments,
    required List<AssessmentPeriod> periods,
  }) : assessments = List<AssessmentStatus>.unmodifiable(assessments),
       periods = List<AssessmentPeriod>.unmodifiable(periods);

  /// The class.
  final ClassroomEntity classroom;

  /// Pupils of the class.
  final int pupilCount;

  /// Its assessments, the latest first.
  final List<AssessmentStatus> assessments;

  /// Its periods, the earliest first.
  final List<AssessmentPeriod> periods;

  /// Whether an assessment is open.
  bool get hasOpenAssessment => assessments.any(
    (AssessmentStatus status) => status.assessment.isOpen,
  );
}
