import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/classroom/data/datasources/assessment_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_tables.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_result_rows.dart';
import 'package:kid_matix/features/classroom/data/models/class_assessment_local_model.dart';
import 'package:kid_matix/features/classroom/data/repositories/classroom_storage_guard.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';

/// [AssessmentRepository] over the local database.
final class AssessmentRepositoryImpl implements AssessmentRepository {
  /// Creates the repository; [clock] dates the rows merged from files.
  const AssessmentRepositoryImpl({
    required this._assessments,
    required this._clock,
    required this._changeBus,
  });

  final AssessmentLocalDataSource _assessments;
  final Clock _clock;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<List<ClassAssessment>>> getAssessments({
    required String classroomId,
  }) {
    return guardClassroomStorage(() async {
      final List<ClassAssessmentLocalModel> rows = await _assessments
          .getAssessments(classroomId: classroomId);
      return rows
          .map((ClassAssessmentLocalModel row) => row.toEntity())
          .toList();
    });
  }

  @override
  Future<DataState<ClassAssessment?>> getAssessment({
    required String assessmentId,
  }) {
    return guardClassroomStorage(() async {
      final ClassAssessmentLocalModel? row = await _assessments.getAssessment(
        assessmentId: assessmentId,
      );
      return row?.toEntity();
    });
  }

  @override
  Future<DataState<void>> saveAssessment({
    required ClassAssessment assessment,
  }) {
    return guardClassroomStorage(() async {
      final bool isWritten = await _assessments.upsertAssessment(
        assessment: ClassAssessmentLocalModel.fromEntity(assessment),
      );
      if (isWritten) {
        _changeBus.notifyChanged(table: ClassroomTables.assessment);
      }
    });
  }

  @override
  Future<DataState<List<AssessmentResult>>> getResults({
    required String classroomId,
  }) {
    return guardClassroomStorage(() async {
      final List<AssessmentResultRows> rows = await _assessments.getResults(
        classroomId: classroomId,
      );
      return rows.map(AssessmentResultMapper.entityOf).toList();
    });
  }

  @override
  Future<DataState<int>> addResults({
    required List<AssessmentResult> results,
  }) {
    return guardClassroomStorage(() async {
      final DateTime now = _clock.now();
      final int added = await _assessments.insertResults(
        results: <AssessmentResultRows>[
          for (final AssessmentResult result in results)
            AssessmentResultMapper.rowsOf(result, updatedAt: now),
        ],
      );
      if (added > 0) {
        _changeBus.notifyChanged(table: ClassroomTables.assessmentResult);
      }
      return added;
    });
  }

  @override
  Stream<void> watchChanges() {
    return _changeBus.watchTables(
      tables: const <String>{
        ClassroomTables.assessment,
        ClassroomTables.assessmentResult,
      },
    );
  }
}
