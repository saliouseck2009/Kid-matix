import 'package:kid_matix/core/entities/placement_level.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/placement_result_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_dashboard.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_overview.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/level_group.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assignment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/class_journal_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/class_challenge_rule.dart';
import 'package:kid_matix/features/classroom/domain/services/class_dashboard_calculator.dart';
import 'package:kid_matix/features/classroom/domain/services/class_item_catalog.dart';
import 'package:kid_matix/features/classroom/domain/services/level_group_rule.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';

/// Reads everything the page of a class shows: its pupils, its current
/// assignment, its dashboard, its level groups and its challenge of the
/// week, all computed from the class results.
///
/// Takes the identifier of the class.
class GetClassOverviewUseCase
    implements UseCase<DataState<ClassOverview>, String> {
  /// Creates the use case.
  const GetClassOverviewUseCase({
    required this._getRoster,
    required this._assignments,
    required this._journal,
    required this._catalog,
    required this._placements,
    required this._clock,
  });

  final GetClassroomRosterUseCase _getRoster;
  final AssignmentRepository _assignments;
  final ClassJournalRepository _journal;
  final ClassItemCatalog _catalog;
  final PlacementResultService _placements;
  final Clock _clock;

  @override
  Future<DataState<ClassOverview>> call({required String params}) async {
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
        DataSuccess<ClassOverview>(await _overviewOf(r, a.lastOrNull, s)),
      (DataFailed<ClassroomRoster>(:final exception), _, _) ||
      (_, DataFailed<List<AssignmentEntity>>(:final exception), _) ||
      (
        _,
        _,
        DataFailed<List<PracticeSession>>(:final exception),
      ) => DataFailed<ClassOverview>(exception),
    };
  }

  Future<ClassOverview> _overviewOf(
    ClassroomRoster roster,
    AssignmentEntity? assignment,
    List<PracticeSession> sessions,
  ) async {
    final ClassDashboard dashboard = ClassDashboardCalculator.compute(
      pupils: roster.pupils,
      sessions: sessions,
      assignmentItemKeys: assignment == null
          ? null
          : _catalog.unitItemKeys(assignment.unitKey),
    );
    final String? groupsDomainId =
        assignment?.domainId ?? _catalog.mostPractisedDomain(sessions);
    return ClassOverview(
      roster: roster,
      assignment: assignment,
      dashboard: dashboard,
      challenge: ClassChallengeRule.compute(
        goal: roster.classroom.weeklyGoal,
        sessions: sessions,
        now: _clock.now(),
      ),
      groupsDomainId: groupsDomainId,
      groups: groupsDomainId == null
          ? const <LevelGroup>[]
          : LevelGroupRule.group(
              pupils: dashboard.pupils,
              classItemKeys: _catalog.itemKeysOf(sessions, groupsDomainId),
              placements: await _placementsOf(roster.pupils, groupsDomainId),
            ),
    );
  }

  Future<Map<String, PlacementLevel>> _placementsOf(
    List<PupilEntity> pupils,
    String domainId,
  ) async {
    final Map<String, PlacementLevel> placements = <String, PlacementLevel>{};
    for (final PupilEntity pupil in pupils) {
      final DataState<PlacementLevel?> read = await _placements.readLatestLevel(
        profileId: pupil.id,
        domainId: domainId,
      );
      // A placement that cannot be read leaves the mastery alone.
      if (read case DataSuccess<PlacementLevel?>(:final PlacementLevel data)) {
        placements[pupil.id] = data;
      }
    }
    return placements;
  }
}
