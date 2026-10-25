import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/qr_results.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/qr_results_codec.dart';
import 'package:kid_matix/features/classroom/domain/services/classroom_merger.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';

/// Merges the results read from a QR code into this tablet, without
/// duplicates, like a class file.
///
/// The code carries no pupil: its class, its pupils and its assessments
/// must already be on this tablet. Fails with an `InvalidFileException`
/// when the text is no results code, and with a `NotFoundException` when
/// the class, a pupil or an assessment is missing (the class file is
/// then needed).
class ReceiveResultsQrUseCase
    implements UseCase<DataState<ClassroomMergeReport>, String> {
  /// Creates the use case.
  const ReceiveResultsQrUseCase({
    required this._codec,
    required this._getRoster,
    required this._assessments,
    required this._merger,
  });

  final QrResultsCodec _codec;
  final GetClassroomRosterUseCase _getRoster;
  final AssessmentRepository _assessments;
  final ClassroomMerger _merger;

  @override
  Future<DataState<ClassroomMergeReport>> call({required String params}) async {
    final QrResults results;
    try {
      results = _codec.decode(params);
    } on AppException catch (exception) {
      return DataFailed<ClassroomMergeReport>(exception);
    }
    final DataState<ClassroomRoster> roster = await _getRoster(
      params: results.classroomId,
    );
    final DataState<List<ClassAssessment>> assessments = await _assessments
        .getAssessments(classroomId: results.classroomId);
    return switch ((roster, assessments)) {
      (
        DataSuccess<ClassroomRoster>(data: final ClassroomRoster r),
        DataSuccess<List<ClassAssessment>>(data: final List<ClassAssessment> a),
      ) =>
        _merge(results, r, a),
      (DataFailed<ClassroomRoster>(), _) =>
        const DataFailed<ClassroomMergeReport>(
          NotFoundException(message: 'Class not on this tablet.'),
        ),
      (_, DataFailed<List<ClassAssessment>>(:final exception)) =>
        DataFailed<ClassroomMergeReport>(exception),
    };
  }

  Future<DataState<ClassroomMergeReport>> _merge(
    QrResults results,
    ClassroomRoster roster,
    List<ClassAssessment> assessments,
  ) async {
    final Set<String> pupilIds = <String>{
      for (final PupilEntity pupil in roster.pupils) pupil.id,
    };
    final Set<String> assessmentIds = <String>{
      for (final ClassAssessment assessment in assessments) assessment.id,
    };
    final bool isKnown =
        results.sessions.every(
          (PracticeSession s) => pupilIds.contains(s.pupilId),
        ) &&
        results.results.every(
          (AssessmentResult r) =>
              pupilIds.contains(r.pupilId) &&
              assessmentIds.contains(r.assessmentId),
        );
    if (!isKnown) {
      return const DataFailed<ClassroomMergeReport>(
        NotFoundException(message: 'Unknown pupil or assessment.'),
      );
    }
    return _merger.merge(
      ClassroomTransfer(
        classroom: roster.classroom,
        pupils: roster.pupils,
        assignments: const [],
        sessions: results.sessions,
        assessments: assessments,
        assessmentResults: results.results,
      ),
    );
  }
}
