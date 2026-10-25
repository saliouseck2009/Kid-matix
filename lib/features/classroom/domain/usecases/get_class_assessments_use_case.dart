import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessments_overview.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/assessment_periods.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';

/// Reads the assessments of a class, how many of its pupils took each
/// one, and its periods.
///
/// Takes the identifier of the class.
class GetClassAssessmentsUseCase
    implements UseCase<DataState<ClassAssessmentsOverview>, String> {
  /// Creates the use case.
  const GetClassAssessmentsUseCase({
    required this._getRoster,
    required this._assessments,
  });

  final GetClassroomRosterUseCase _getRoster;
  final AssessmentRepository _assessments;

  @override
  Future<DataState<ClassAssessmentsOverview>> call({
    required String params,
  }) async {
    final DataState<ClassroomRoster> roster = await _getRoster(params: params);
    final DataState<List<ClassAssessment>> assessments = await _assessments
        .getAssessments(classroomId: params);
    final DataState<List<AssessmentResult>> results = await _assessments
        .getResults(classroomId: params);
    return switch ((roster, assessments, results)) {
      (
        DataSuccess<ClassroomRoster>(data: final ClassroomRoster r),
        DataSuccess<List<ClassAssessment>>(data: final List<ClassAssessment> a),
        DataSuccess<List<AssessmentResult>>(
          data: final List<AssessmentResult> s,
        ),
      ) =>
        DataSuccess<ClassAssessmentsOverview>(overviewOf(r, a, s)),
      (DataFailed<ClassroomRoster>(:final exception), _, _) ||
      (_, DataFailed<List<ClassAssessment>>(:final exception), _) ||
      (
        _,
        _,
        DataFailed<List<AssessmentResult>>(:final exception),
      ) => DataFailed<ClassAssessmentsOverview>(exception),
    };
  }

  /// The overview of [roster] with its [assessments] and [results]; only
  /// the results of pupils still in the class count.
  static ClassAssessmentsOverview overviewOf(
    ClassroomRoster roster,
    List<ClassAssessment> assessments,
    List<AssessmentResult> results,
  ) {
    final Set<String> pupilIds = <String>{
      for (final PupilEntity pupil in roster.pupils) pupil.id,
    };
    final Map<String, int> takenCounts = <String, int>{};
    for (final AssessmentResult result in results) {
      if (!pupilIds.contains(result.pupilId)) continue;
      takenCounts[result.assessmentId] =
          (takenCounts[result.assessmentId] ?? 0) + 1;
    }
    return ClassAssessmentsOverview(
      classroom: roster.classroom,
      pupilCount: roster.pupils.length,
      assessments: <AssessmentStatus>[
        for (final ClassAssessment assessment in assessments.reversed)
          (
            assessment: assessment,
            takenCount: takenCounts[assessment.id] ?? 0,
          ),
      ],
      periods: AssessmentPeriods.of(assessments),
    );
  }
}
