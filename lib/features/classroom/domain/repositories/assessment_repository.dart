import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';

/// The assessments of the classes and the results of their pupils.
///
/// Filled by the teacher, by the pupils who take them and by the class
/// files received from other tablets.
abstract interface class AssessmentRepository {
  /// Returns the live assessments of [classroomId], oldest first.
  Future<DataState<List<ClassAssessment>>> getAssessments({
    required String classroomId,
  });

  /// Returns the assessment [assessmentId], or `null` when it does not
  /// exist.
  Future<DataState<ClassAssessment?>> getAssessment({
    required String assessmentId,
  });

  /// Keeps [assessment], or replaces the stored one with the same id when
  /// [assessment] is newer.
  Future<DataState<void>> saveAssessment({
    required ClassAssessment assessment,
  });

  /// Returns the results of the pupils of [classroomId], oldest first.
  Future<DataState<List<AssessmentResult>>> getResults({
    required String classroomId,
  });

  /// Adds [results]; a result already kept (same assessment and pupil) is
  /// left as it is. Resolves to how many were added.
  Future<DataState<int>> addResults({required List<AssessmentResult> results});

  /// Emits an event after each change to the assessments or results.
  Stream<void> watchChanges();
}
