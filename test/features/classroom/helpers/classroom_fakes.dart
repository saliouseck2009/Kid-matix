import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/entities/pupil_draft.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/services/placement_result_service.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/features/classroom/domain/services/class_item_catalog.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_class_overview_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/set_weekly_goal_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_use_cases.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assignment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/class_journal_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/pupil_enrollment.dart';
import 'package:kid_matix/features/classroom/domain/usecases/add_pupils_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/close_teacher_area_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/find_unusable_nicknames_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classrooms_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/select_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/watch_classroom_changes_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_list_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_use_cases.dart';

import 'classroom_device.dart';

/// [ClassroomRepository] kept in memory.
final class InMemoryClassrooms implements ClassroomRepository {
  /// The classes, by identifier.
  final Map<String, ClassroomEntity> rows = <String, ClassroomEntity>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Future<DataState<List<ClassroomEntity>>> getClassrooms() async {
    return DataSuccess<List<ClassroomEntity>>(rows.values.toList());
  }

  @override
  Future<DataState<ClassroomEntity>> getClassroom({
    required String classroomId,
  }) async {
    final ClassroomEntity? row = rows[classroomId];
    if (row == null) {
      return const DataFailed<ClassroomEntity>(NotFoundException());
    }
    return DataSuccess<ClassroomEntity>(row);
  }

  @override
  Future<DataState<void>> createClassroom({
    required ClassroomEntity classroom,
  }) async {
    rows[classroom.id] = classroom;
    _changes.add(null);
    return const DataSuccess<void>(null);
  }

  @override
  Future<DataState<void>> updateClassroom({
    required ClassroomEntity classroom,
  }) => createClassroom(classroom: classroom);

  @override
  Future<DataState<void>> mergeClassroom({
    required ClassroomEntity classroom,
  }) => createClassroom(classroom: classroom);

  @override
  Stream<void> watchChanges() => _changes.stream;
}

/// [AssignmentRepository] kept in memory.
final class InMemoryAssignments implements AssignmentRepository {
  /// The assignments, in the order they were saved.
  final List<AssignmentEntity> rows = <AssignmentEntity>[];

  @override
  Future<DataState<List<AssignmentEntity>>> getAssignments({
    required String classroomId,
  }) async {
    return DataSuccess<List<AssignmentEntity>>(
      rows.where((AssignmentEntity a) => a.classroomId == classroomId).toList(),
    );
  }

  @override
  Future<DataState<void>> saveAssignment({
    required AssignmentEntity assignment,
  }) async {
    rows
      ..removeWhere((AssignmentEntity a) => a.id == assignment.id)
      ..add(assignment);
    return const DataSuccess<void>(null);
  }

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}

/// [ClassJournalRepository] kept in memory.
final class InMemoryJournal implements ClassJournalRepository {
  /// The sessions, by identifier.
  final Map<String, PracticeSession> rows = <String, PracticeSession>{};

  @override
  Future<DataState<List<PracticeSession>>> getSessions({
    required String classroomId,
  }) async {
    return DataSuccess<List<PracticeSession>>(
      rows.values
          .where((PracticeSession s) => s.classroomId == classroomId)
          .toList(),
    );
  }

  @override
  Future<DataState<int>> addSessions({
    required List<PracticeSession> sessions,
  }) async {
    int added = 0;
    for (final PracticeSession session in sessions) {
      if (rows.containsKey(session.id)) continue;
      rows[session.id] = session;
      added++;
    }
    return DataSuccess<int>(added);
  }

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}

/// [PupilRosterService] kept in memory; nicknames of one or two letters
/// cannot be used.
final class InMemoryRoster implements PupilRosterService {
  /// The pupils, by class.
  final Map<String, List<PlayerIdentity>> pupils =
      <String, List<PlayerIdentity>>{};

  /// The pupil opened last.
  String? selectedId;

  @override
  Future<DataState<List<PlayerIdentity>>> readPupils({
    required String classroomId,
  }) async {
    return DataSuccess<List<PlayerIdentity>>(
      List<PlayerIdentity>.of(pupils[classroomId] ?? <PlayerIdentity>[]),
    );
  }

  @override
  Future<DataState<String?>> readClassroomOf({
    required String profileId,
  }) async {
    for (final MapEntry<String, List<PlayerIdentity>> entry in pupils.entries) {
      if (entry.value.any((PlayerIdentity pupil) => pupil.id == profileId)) {
        return DataSuccess<String?>(entry.key);
      }
    }
    return const DataSuccess<String?>(null);
  }

  @override
  List<String> findUnusableNicknames(List<String> nicknames) {
    return nicknames.where((String nickname) => nickname.length < 2).toList();
  }

  @override
  Future<DataState<int>> addPupils({
    required String classroomId,
    required List<PupilDraft> pupils,
  }) async {
    final List<PlayerIdentity> list = this.pupils.putIfAbsent(
      classroomId,
      () => <PlayerIdentity>[],
    );
    for (final PupilDraft pupil in pupils) {
      list.add(
        PlayerIdentity(
          id: pupil.id,
          nickname: pupil.nickname,
          avatarKey: 'avatar1',
          colorKey: 'violet',
        ),
      );
    }
    return DataSuccess<int>(pupils.length);
  }

  @override
  Future<DataState<void>> selectPupil({required String profileId}) async {
    selectedId = profileId;
    return const DataSuccess<void>(null);
  }

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}

/// The use cases of the class mode over [InMemoryClassrooms] and
/// [InMemoryRoster].
final class FakeClassroomStack {
  /// The classes.
  final InMemoryClassrooms classrooms = InMemoryClassrooms();

  /// The pupils.
  final InMemoryRoster roster = InMemoryRoster();

  /// The assignments.
  final InMemoryAssignments assignments = InMemoryAssignments();

  /// The results.
  final InMemoryJournal journal = InMemoryJournal();

  /// Identifiers.
  final CountingIds ids = CountingIds('id');

  late final PupilEnrollment _enrollment = PupilEnrollment(
    roster: roster,
    ids: ids,
  );

  late final GetClassroomRosterUseCase _getRoster = GetClassroomRosterUseCase(
    repository: classrooms,
    roster: roster,
  );

  late final WatchClassroomChangesUseCase _watch = WatchClassroomChangesUseCase(
    repository: classrooms,
    roster: roster,
    assignments: assignments,
    journal: journal,
  );

  /// Creates classes.
  late final CreateClassroomUseCase create = CreateClassroomUseCase(
    repository: classrooms,
    enrollment: _enrollment,
    ids: ids,
    clock: MovableClock(DateTime(2026, 10, 20, 9)),
  );

  /// The use cases of the form.
  late final ClassroomFormUseCases form = ClassroomFormUseCases(
    create: create,
    addPupils: AddPupilsUseCase(roster: roster, enrollment: _enrollment),
    findUnusable: FindUnusableNicknamesUseCase(enrollment: _enrollment),
    getRoster: _getRoster,
  );

  /// The use cases of the lists of pupils.
  late final ClassroomRosterUseCases rosterUseCases = ClassroomRosterUseCases(
    getRoster: _getRoster,
    selectPupil: SelectPupilUseCase(roster: roster),
    watchChanges: _watch,
  );

  /// The learning domains: multiplication only.
  late final DomainRegistry domains = DomainRegistry()
    ..register(MultiplicationDomain());

  late final ClassItemCatalog _catalog = ClassItemCatalog(domains: domains);

  /// The use cases of the page of a class.
  late final ClassOverviewUseCases overviewUseCases = ClassOverviewUseCases(
    getOverview: GetClassOverviewUseCase(
      getRoster: _getRoster,
      assignments: assignments,
      journal: journal,
      catalog: _catalog,
      placements: const NoPlacementResultService(),
      clock: MovableClock(DateTime(2026, 10, 21, 9)),
    ),
    setWeeklyGoal: SetWeeklyGoalUseCase(
      repository: classrooms,
      clock: MovableClock(DateTime(2026, 10, 21, 9)),
    ),
    watchChanges: _watch,
  );

  /// Gives assignments.
  late final GiveAssignmentUseCase giveAssignment = GiveAssignmentUseCase(
    assignments: assignments,
    catalog: _catalog,
    ids: ids,
    clock: MovableClock(DateTime(2026, 10, 21, 9)),
  );

  /// The use cases of the lists of classes.
  ClassroomListUseCases listUseCases(CloseTeacherAreaUseCase closeArea) {
    return ClassroomListUseCases(
      getClassrooms: GetClassroomsUseCase(
        repository: classrooms,
        roster: roster,
      ),
      watchChanges: _watch,
      closeArea: closeArea,
    );
  }
}

/// Draws an avatar as an empty box of [size].
Widget boxAvatar(PlayerIdentity player, double size) {
  return SizedBox.square(dimension: size);
}
