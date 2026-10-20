import 'package:kid_matix/core/entities/pupil_draft.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assignment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/class_journal_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';

/// Merges a class file into this tablet, without duplicates: the class,
/// then its pupils, its assignments and the sessions of its pupils, each
/// by its identifier.
///
/// Every step only adds what is missing (or a newer class name, goal or
/// assignment), so a file received twice changes nothing the second
/// time, and a merge stopped by a failure is finished by merging the
/// file again.
class ClassroomMerger {
  /// Creates the merger.
  const ClassroomMerger({
    required this._classrooms,
    required this._roster,
    required this._assignments,
    required this._journal,
  });

  final ClassroomRepository _classrooms;
  final PupilRosterService _roster;
  final AssignmentRepository _assignments;
  final ClassJournalRepository _journal;

  /// Merges [transfer]; fails with an `InvalidFileException` when a part
  /// of it points to another class or to a pupil it does not carry.
  Future<DataState<ClassroomMergeReport>> merge(
    ClassroomTransfer transfer,
  ) async {
    if (!_isConsistent(transfer)) {
      return const DataFailed<ClassroomMergeReport>(
        InvalidFileException(message: 'Class file not consistent.'),
      );
    }
    final DataState<void> classroom = await _classrooms.mergeClassroom(
      classroom: transfer.classroom,
    );
    if (classroom case DataFailed<void>(:final exception)) {
      return DataFailed<ClassroomMergeReport>(exception);
    }
    final DataState<int> pupils = await _roster.addPupils(
      classroomId: transfer.classroom.id,
      pupils: transfer.pupils.map(_draftOf).toList(),
    );
    if (pupils case DataFailed<int>(:final exception)) {
      return DataFailed<ClassroomMergeReport>(exception);
    }
    final AppException? problem = await _mergeAssignments(transfer);
    if (problem != null) return DataFailed<ClassroomMergeReport>(problem);
    return switch (await _journal.addSessions(sessions: transfer.sessions)) {
      DataFailed<int>(:final exception) => DataFailed<ClassroomMergeReport>(
        exception,
      ),
      DataSuccess<int>(:final data) => DataSuccess<ClassroomMergeReport>(
        ClassroomMergeReport(
          classroomName: transfer.classroom.name,
          addedPupilCount: (pupils as DataSuccess<int>).data,
          addedSessionCount: data,
        ),
      ),
    };
  }

  Future<AppException?> _mergeAssignments(ClassroomTransfer transfer) async {
    for (final AssignmentEntity assignment in transfer.assignments) {
      final DataState<void> saved = await _assignments.saveAssignment(
        assignment: assignment,
      );
      if (saved case DataFailed<void>(:final exception)) return exception;
    }
    return null;
  }

  static bool _isConsistent(ClassroomTransfer transfer) {
    final String classroomId = transfer.classroom.id;
    final Set<String> pupilIds = <String>{
      for (final PupilEntity pupil in transfer.pupils) pupil.id,
    };
    return transfer.pupils.every(
          (PupilEntity p) => p.classroomId == classroomId,
        ) &&
        transfer.assignments.every(
          (AssignmentEntity a) => a.classroomId == classroomId,
        ) &&
        transfer.sessions.every(
          (PracticeSession s) =>
              s.classroomId == classroomId && pupilIds.contains(s.pupilId),
        );
  }

  static PupilDraft _draftOf(PupilEntity pupil) {
    return PupilDraft(
      id: pupil.id,
      nickname: pupil.nickname,
      avatarKey: pupil.player.avatarKey,
      colorKey: pupil.player.colorKey,
    );
  }
}
