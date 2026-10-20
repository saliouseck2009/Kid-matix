import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_class_view.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assignment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/class_journal_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/class_challenge_rule.dart';
import 'package:kid_matix/features/classroom/domain/services/class_item_catalog.dart';
import 'package:kid_matix/features/classroom/domain/services/item_standing_rule.dart';
import 'package:kid_matix/features/classroom/domain/entities/item_standing.dart';

/// Reads what a player sees of their class on the home, or `null` for a
/// free player.
///
/// Takes the identifier of the player.
class GetPupilClassViewUseCase
    implements UseCase<DataState<PupilClassView?>, String> {
  /// Creates the use case.
  const GetPupilClassViewUseCase({
    required this._roster,
    required this._classrooms,
    required this._assignments,
    required this._journal,
    required this._catalog,
    required this._clock,
  });

  final PupilRosterService _roster;
  final ClassroomRepository _classrooms;
  final AssignmentRepository _assignments;
  final ClassJournalRepository _journal;
  final ClassItemCatalog _catalog;
  final Clock _clock;

  @override
  Future<DataState<PupilClassView?>> call({required String params}) async {
    final DataState<String?> classroomOf = await _roster.readClassroomOf(
      profileId: params,
    );
    final String? classroomId = switch (classroomOf) {
      DataSuccess<String?>(:final data) => data,
      DataFailed<String?>() => null,
    };
    if (classroomId == null) return const DataSuccess<PupilClassView?>(null);
    final DataState<ClassroomEntity> classroom = await _classrooms.getClassroom(
      classroomId: classroomId,
    );
    final DataState<List<AssignmentEntity>> assignments = await _assignments
        .getAssignments(classroomId: classroomId);
    final DataState<List<PracticeSession>> sessions = await _journal
        .getSessions(classroomId: classroomId);
    return switch ((classroom, assignments, sessions)) {
      (
        DataSuccess<ClassroomEntity>(data: final ClassroomEntity c),
        DataSuccess<List<AssignmentEntity>>(
          data: final List<AssignmentEntity> a,
        ),
        DataSuccess<List<PracticeSession>>(data: final List<PracticeSession> s),
      ) =>
        DataSuccess<PupilClassView?>(_viewOf(params, c, a.lastOrNull, s)),
      (DataFailed<ClassroomEntity>(:final exception), _, _) ||
      (_, DataFailed<List<AssignmentEntity>>(:final exception), _) ||
      (
        _,
        _,
        DataFailed<List<PracticeSession>>(:final exception),
      ) => DataFailed<PupilClassView?>(exception),
    };
  }

  PupilClassView _viewOf(
    String pupilId,
    ClassroomEntity classroom,
    AssignmentEntity? assignment,
    List<PracticeSession> sessions,
  ) {
    return PupilClassView(
      classroom: classroom,
      assignment: assignment,
      assignmentProgress: assignment == null
          ? null
          : _progressOn(assignment, pupilId, sessions),
      challenge: ClassChallengeRule.compute(
        goal: classroom.weeklyGoal,
        sessions: sessions,
        now: _clock.now(),
      ),
    );
  }

  double _progressOn(
    AssignmentEntity assignment,
    String pupilId,
    List<PracticeSession> sessions,
  ) {
    final Set<String> itemKeys = _catalog.unitItemKeys(assignment.unitKey);
    if (itemKeys.isEmpty) return 0;
    final Map<String, ItemStanding> standings = ItemStandingRule.standingsOf(
      sessions.where((PracticeSession s) => s.pupilId == pupilId),
    );
    final int acquired = itemKeys
        .where((String key) => standings[key] == ItemStanding.acquired)
        .length;
    return acquired / itemKeys.length;
  }
}
