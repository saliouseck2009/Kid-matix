import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/entities/export_mark.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assignment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/class_journal_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_transfer_repository.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';

/// Writes a class to a file and opens the share sheet: its pupils, its
/// assignments and the results of its pupils on this tablet. The same
/// file gives the class to a new tablet and brings the results to the
/// teacher's.
///
/// A delta file by default: the sessions written on this tablet after
/// the local sequence its last shared file reached, plus every session
/// of the last [overlap] (resent on purpose: a second receiver or a lost
/// file still gets them, and the merge ignores duplicates); `isFull`
/// sends them all. The mark moves only once the share succeeded. The
/// assessments of the class and their results always go whole: they are
/// few, and the merge ignores those already kept.
class ExportClassroomUseCase
    implements UseCase<DataState<bool>, ({String classroomId, bool isFull})> {
  /// Creates the use case.
  const ExportClassroomUseCase({
    required this._getRoster,
    required this._assignments,
    required this._journal,
    required this._assessments,
    required this._transfers,
    required this._clock,
  });

  /// Sessions always resent by a delta file.
  static const Duration overlap = Duration(days: 14);

  final GetClassroomRosterUseCase _getRoster;
  final AssignmentRepository _assignments;
  final ClassJournalRepository _journal;
  final AssessmentRepository _assessments;
  final ClassroomTransferRepository _transfers;
  final Clock _clock;

  @override
  Future<DataState<bool>> call({
    required ({String classroomId, bool isFull}) params,
  }) async {
    final String classroomId = params.classroomId;
    final DateTime now = _clock.now();
    final DataState<ExportMark?> mark = params.isFull
        ? const DataSuccess<ExportMark?>(null)
        : await _transfers.readExportMark(classroomId: classroomId);
    final DataState<int> latest = await _journal.getLatestSequence(
      classroomId: classroomId,
    );
    switch ((mark, latest)) {
      case (DataFailed<ExportMark?>(:final exception), _) ||
          (_, DataFailed<int>(:final exception)):
        return DataFailed<bool>(exception);
      case _:
        break;
    }
    final DataState<ClassroomTransfer> transfer = await _withAssessments(
      await _transferOf(
        classroomId,
        (mark as DataSuccess<ExportMark?>).data?.sequence,
        now.subtract(overlap),
      ),
    );
    if (transfer case DataFailed<ClassroomTransfer>(:final exception)) {
      return DataFailed<bool>(exception);
    }
    final DataState<bool> shared = await _transfers.share(
      transfer: (transfer as DataSuccess<ClassroomTransfer>).data,
    );
    if (shared case DataSuccess<bool>(data: true)) {
      await _transfers.saveExportMark(
        classroomId: classroomId,
        mark: ExportMark(
          sequence: (latest as DataSuccess<int>).data,
          exportedAt: now,
        ),
      );
    }
    return shared;
  }

  /// [transfer] with the assessments of its class and the results of its
  /// pupils in them.
  Future<DataState<ClassroomTransfer>> _withAssessments(
    DataState<ClassroomTransfer> transfer,
  ) async {
    if (transfer is! DataSuccess<ClassroomTransfer>) return transfer;
    final ClassroomTransfer data = transfer.data;
    final String id = data.classroom.id;
    final DataState<List<ClassAssessment>> assessments = await _assessments
        .getAssessments(classroomId: id);
    final DataState<List<AssessmentResult>> results = await _assessments
        .getResults(classroomId: id);
    final Set<String> pupilIds = <String>{
      for (final PupilEntity pupil in data.pupils) pupil.id,
    };
    return switch ((assessments, results)) {
      (
        DataSuccess<List<ClassAssessment>>(data: final List<ClassAssessment> a),
        DataSuccess<List<AssessmentResult>>(
          data: final List<AssessmentResult> r,
        ),
      ) =>
        DataSuccess<ClassroomTransfer>(
          data.copyWith(
            assessments: a,
            assessmentResults: r
                .where((AssessmentResult x) => pupilIds.contains(x.pupilId))
                .toList(),
          ),
        ),
      (DataFailed<List<ClassAssessment>>(:final exception), _) ||
      (
        _,
        DataFailed<List<AssessmentResult>>(:final exception),
      ) => DataFailed<ClassroomTransfer>(exception),
    };
  }

  Future<DataState<ClassroomTransfer>> _transferOf(
    String classroomId,
    int? afterSequence,
    DateTime overlapStart,
  ) async {
    final DataState<ClassroomRoster> roster = await _getRoster(
      params: classroomId,
    );
    final DataState<List<AssignmentEntity>> assignments = await _assignments
        .getAssignments(classroomId: classroomId);
    final DataState<List<PracticeSession>> sessions = await _journal
        .getSessions(
          classroomId: classroomId,
          afterSequence: afterSequence,
          startedFrom: afterSequence == null ? null : overlapStart,
        );
    return switch ((roster, assignments, sessions)) {
      (
        DataSuccess<ClassroomRoster>(data: final ClassroomRoster r),
        DataSuccess<List<AssignmentEntity>>(
          data: final List<AssignmentEntity> a,
        ),
        DataSuccess<List<PracticeSession>>(data: final List<PracticeSession> s),
      ) =>
        DataSuccess<ClassroomTransfer>(
          ClassroomTransfer(
            classroom: r.classroom,
            pupils: r.pupils,
            assignments: a,
            sessions: s,
          ),
        ),
      (DataFailed<ClassroomRoster>(:final exception), _, _) ||
      (_, DataFailed<List<AssignmentEntity>>(:final exception), _) ||
      (
        _,
        _,
        DataFailed<List<PracticeSession>>(:final exception),
      ) => DataFailed<ClassroomTransfer>(exception),
    };
  }
}
