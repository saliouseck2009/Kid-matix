import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assignment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/class_journal_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_transfer_repository.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';

/// Writes a class to a file and opens the share sheet: its pupils, its
/// assignments and the results of its pupils on this tablet. The same
/// file gives the class to a new tablet and brings the results to the
/// teacher's.
///
/// Takes the identifier of the class; resolves to whether it was
/// shared.
class ExportClassroomUseCase implements UseCase<DataState<bool>, String> {
  /// Creates the use case.
  const ExportClassroomUseCase({
    required this._getRoster,
    required this._assignments,
    required this._journal,
    required this._transfers,
  });

  final GetClassroomRosterUseCase _getRoster;
  final AssignmentRepository _assignments;
  final ClassJournalRepository _journal;
  final ClassroomTransferRepository _transfers;

  @override
  Future<DataState<bool>> call({required String params}) async {
    final DataState<ClassroomRoster> roster = await _getRoster(params: params);
    final DataState<List<AssignmentEntity>> assignments = await _assignments
        .getAssignments(classroomId: params);
    final DataState<List<PracticeSession>> sessions = await _journal
        .getSessions(classroomId: params);
    return switch ((roster, assignments, sessions)) {
      (
        DataSuccess<ClassroomRoster>(data: final ClassroomRoster r),
        DataSuccess<List<AssignmentEntity>>(
          data: final List<AssignmentEntity> a,
        ),
        DataSuccess<List<PracticeSession>>(data: final List<PracticeSession> s),
      ) =>
        await _transfers.share(
          transfer: ClassroomTransfer(
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
      ) => DataFailed<bool>(exception),
    };
  }
}
