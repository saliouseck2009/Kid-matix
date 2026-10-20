import 'package:kid_matix/core/entities/player_identity.dart';
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
import 'package:kid_matix/features/classroom/domain/services/pupil_merge.dart';

/// Merges a class file into this tablet, without duplicates: the class,
/// then its pupils one by one, its assignments and the sessions of its
/// pupils, each by its identifier.
///
/// Every step only adds what is missing, or a class name, goal or
/// assignment whose `updated_at` is newer (so the clocks of the tablets
/// should be right). A file received twice changes nothing the second
/// time, and a merge stopped by a failure is finished by merging the file
/// again.
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
  /// of it points to another class or to a pupil it does not carry, and
  /// with a `LimitReachedException` when the class would hold more than
  /// [PupilRosterService.maxPupilsPerClass] pupils. A pupil whose
  /// nickname is taken in the class by another pupil is renamed.
  Future<DataState<ClassroomMergeReport>> merge(
    ClassroomTransfer transfer,
  ) async {
    final AppException? problem =
        _findInconsistency(transfer) ?? await _findCapacityProblem(transfer);
    if (problem != null) return DataFailed<ClassroomMergeReport>(problem);
    final DataState<void> classroom = await _classrooms.mergeClassroom(
      classroom: transfer.classroom,
    );
    if (classroom case DataFailed<void>(:final exception)) {
      return DataFailed<ClassroomMergeReport>(exception);
    }
    final DataState<PupilMerge> pupils = await PupilMerge.run(
      roster: _roster,
      classroomId: transfer.classroom.id,
      pupils: transfer.pupils,
    );
    if (pupils case DataFailed<PupilMerge>(:final exception)) {
      return DataFailed<ClassroomMergeReport>(exception);
    }
    final AppException? failure = await _mergeAssignments(transfer);
    if (failure != null) return DataFailed<ClassroomMergeReport>(failure);
    return _mergeSessions(transfer, (pupils as DataSuccess<PupilMerge>).data);
  }

  Future<DataState<ClassroomMergeReport>> _mergeSessions(
    ClassroomTransfer transfer,
    PupilMerge pupils,
  ) async {
    return switch (await _journal.addSessions(sessions: transfer.sessions)) {
      DataFailed<int>(:final exception) => DataFailed<ClassroomMergeReport>(
        exception,
      ),
      DataSuccess<int>(:final data) => DataSuccess<ClassroomMergeReport>(
        ClassroomMergeReport(
          classroomName: transfer.classroom.name,
          addedPupilCount: pupils.addedCount,
          addedSessionCount: data,
          renamedNicknames: pupils.renamedNicknames,
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

  Future<AppException?> _findCapacityProblem(ClassroomTransfer transfer) async {
    final DataState<List<PlayerIdentity>> current = await _roster.readPupils(
      classroomId: transfer.classroom.id,
    );
    if (current case DataFailed<List<PlayerIdentity>>(:final exception)) {
      return exception;
    }
    final Set<String> ids = <String>{
      for (final PlayerIdentity pupil
          in (current as DataSuccess<List<PlayerIdentity>>).data)
        pupil.id,
      for (final PupilEntity pupil in transfer.pupils) pupil.id,
    };
    if (ids.length <= PupilRosterService.maxPupilsPerClass) return null;
    return const LimitReachedException(message: 'Too many pupils.');
  }

  static AppException? _findInconsistency(ClassroomTransfer transfer) {
    final String classroomId = transfer.classroom.id;
    final Set<String> pupilIds = <String>{
      for (final PupilEntity pupil in transfer.pupils) pupil.id,
    };
    final bool isConsistent =
        transfer.pupils.every(
          (PupilEntity p) => p.classroomId == classroomId,
        ) &&
        transfer.assignments.every(
          (AssignmentEntity a) => a.classroomId == classroomId,
        ) &&
        transfer.sessions.every(
          (PracticeSession s) =>
              s.classroomId == classroomId && pupilIds.contains(s.pupilId),
        );
    return isConsistent
        ? null
        : const InvalidFileException(message: 'Class file not consistent.');
  }
}
