import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:meta/meta.dart';

/// What a class file carries from one tablet to another, with no
/// network: the class, its pupils, its assignments, the results of its
/// pupils, its assessments and their results (F31).
///
/// Merging it is idempotent: every part keeps the identifiers of the
/// tablet it was made on.
@immutable
final class ClassroomTransfer {
  /// Creates the transfer of [classroom].
  const ClassroomTransfer({
    required this.classroom,
    required this.pupils,
    required this.assignments,
    required this.sessions,
    this.assessments = const <ClassAssessment>[],
    this.assessmentResults = const <AssessmentResult>[],
  });

  /// The class.
  final ClassroomEntity classroom;

  /// Its pupils, in the order of the class list.
  final List<PupilEntity> pupils;

  /// Its assignments, oldest first.
  final List<AssignmentEntity> assignments;

  /// The sessions its pupils played, with their answers.
  final List<PracticeSession> sessions;

  /// Its assessments, oldest first.
  final List<ClassAssessment> assessments;

  /// The results of its pupils in those assessments.
  final List<AssessmentResult> assessmentResults;

  /// Returns a copy with the given fields replaced.
  ClassroomTransfer copyWith({
    ClassroomEntity? classroom,
    List<PupilEntity>? pupils,
    List<AssignmentEntity>? assignments,
    List<PracticeSession>? sessions,
    List<ClassAssessment>? assessments,
    List<AssessmentResult>? assessmentResults,
  }) {
    return ClassroomTransfer(
      classroom: classroom ?? this.classroom,
      pupils: pupils ?? this.pupils,
      assignments: assignments ?? this.assignments,
      sessions: sessions ?? this.sessions,
      assessments: assessments ?? this.assessments,
      assessmentResults: assessmentResults ?? this.assessmentResults,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClassroomTransfer &&
            other.classroom == classroom &&
            Object.hashAll(other.pupils) == Object.hashAll(pupils) &&
            Object.hashAll(other.assignments) == Object.hashAll(assignments) &&
            Object.hashAll(other.sessions) == Object.hashAll(sessions) &&
            Object.hashAll(other.assessments) == Object.hashAll(assessments) &&
            Object.hashAll(other.assessmentResults) ==
                Object.hashAll(assessmentResults);
  }

  @override
  int get hashCode => Object.hash(
    classroom,
    Object.hashAll(pupils),
    Object.hashAll(assignments),
    Object.hashAll(sessions),
    Object.hashAll(assessments),
    Object.hashAll(assessmentResults),
  );
}
