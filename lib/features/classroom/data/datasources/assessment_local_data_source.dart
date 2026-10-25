import 'package:kid_matix/features/classroom/data/models/assessment_result_rows.dart';
import 'package:kid_matix/features/classroom/data/models/class_assessment_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// The assessments and their results stored in the local SQLite
/// database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository
/// turns them into typed failures.
abstract interface class AssessmentLocalDataSource {
  /// Returns the live assessments of [classroomId], oldest first.
  Future<List<ClassAssessmentLocalModel>> getAssessments({
    required String classroomId,
  });

  /// Returns the live assessment [assessmentId], or `null`.
  Future<ClassAssessmentLocalModel?> getAssessment({
    required String assessmentId,
  });

  /// Inserts [assessment], or replaces the stored row with the same id
  /// when [assessment] is newer; returns whether a row was written.
  Future<bool> upsertAssessment({
    required ClassAssessmentLocalModel assessment,
  });

  /// Returns the live results of the assessments of [classroomId] with
  /// their levels and words, oldest first.
  Future<List<AssessmentResultRows>> getResults({required String classroomId});

  /// Inserts [results] in one transaction; returns how many were new.
  Future<int> insertResults({required List<AssessmentResultRows> results});

  /// Inserts [rows] with [executor] unless that pupil's result of that
  /// assessment is already kept; returns whether it was new. Used inside
  /// the transaction that saves a quiz session.
  Future<bool> insertResultWith(
    DatabaseExecutor executor,
    AssessmentResultRows rows,
  );
}
