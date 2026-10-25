import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';

/// Reads the assessment a pupil still has to take: the latest open
/// assessment of their class they have no result in, or `null` (always
/// for a free player).
///
/// Takes the identifier of the player.
class GetPendingAssessmentUseCase
    implements UseCase<DataState<ClassAssessment?>, String> {
  /// Creates the use case.
  const GetPendingAssessmentUseCase({
    required this._roster,
    required this._assessments,
  });

  final PupilRosterService _roster;
  final AssessmentRepository _assessments;

  @override
  Future<DataState<ClassAssessment?>> call({required String params}) async {
    final DataState<String?> classroomOf = await _roster.readClassroomOf(
      profileId: params,
    );
    if (classroomOf case DataFailed<String?>(:final exception)) {
      return DataFailed<ClassAssessment?>(exception);
    }
    final String? classroomId = (classroomOf as DataSuccess<String?>).data;
    if (classroomId == null) return const DataSuccess<ClassAssessment?>(null);
    final DataState<List<ClassAssessment>> assessments = await _assessments
        .getAssessments(classroomId: classroomId);
    final DataState<List<AssessmentResult>> results = await _assessments
        .getResults(classroomId: classroomId);
    return switch ((assessments, results)) {
      (
        DataSuccess<List<ClassAssessment>>(data: final List<ClassAssessment> a),
        DataSuccess<List<AssessmentResult>>(
          data: final List<AssessmentResult> r,
        ),
      ) =>
        DataSuccess<ClassAssessment?>(_pendingOf(params, a, r)),
      (DataFailed<List<ClassAssessment>>(:final exception), _) ||
      (
        _,
        DataFailed<List<AssessmentResult>>(:final exception),
      ) => DataFailed<ClassAssessment?>(exception),
    };
  }

  static ClassAssessment? _pendingOf(
    String pupilId,
    List<ClassAssessment> assessments,
    List<AssessmentResult> results,
  ) {
    final Set<String> taken = <String>{
      for (final AssessmentResult result in results)
        if (result.pupilId == pupilId) result.assessmentId,
    };
    for (final ClassAssessment assessment in assessments.reversed) {
      if (assessment.isOpen && !taken.contains(assessment.id)) {
        return assessment;
      }
    }
    return null;
  }
}
