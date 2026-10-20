import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/entities/pupil_draft.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/pupil_enrollment.dart';
import 'package:kid_matix/features/classroom/domain/usecases/add_pupils_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/close_teacher_area_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/find_unusable_nicknames_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classrooms_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/remove_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/reset_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/select_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/watch_classroom_changes_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_list_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_use_cases.dart';

import 'package:kid_matix/core/services/teacher_session_service.dart';
import 'package:kid_matix/features/classroom/data/repositories/teacher_code_repository_impl.dart';
import 'package:kid_matix/features/classroom/domain/services/teacher_code_attempts.dart';
import 'package:kid_matix/features/classroom/domain/usecases/choose_teacher_code_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/forget_teacher_code_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_teacher_access_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/open_teacher_area_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_access_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/classroom_pages.dart';

import '../../../helpers/in_memory_local_storage.dart';
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
  Future<DataState<void>> deleteEmptyClassroom({
    required String classroomId,
  }) async {
    rows.remove(classroomId);
    return const DataSuccess<void>(null);
  }

  @override
  Stream<void> watchChanges() => _changes.stream;
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
  List<String> findUnusableNicknames(List<String> nicknames) {
    return nicknames.where((String nickname) => nickname.length < 2).toList();
  }

  /// Whether the next [addPupils] fails, like a database error.
  bool failsNextAddition = false;

  @override
  Future<DataState<int>> addPupils({
    required String classroomId,
    required List<PupilDraft> pupils,
  }) async {
    if (failsNextAddition) {
      failsNextAddition = false;
      return const DataFailed<int>(CacheException(message: 'Disk full.'));
    }
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

  /// The pupils whose progress was reset.
  final List<String> resetIds = <String>[];

  @override
  Future<DataState<void>> resetPupil({required String profileId}) async {
    resetIds.add(profileId);
    return const DataSuccess<void>(null);
  }

  @override
  Future<DataState<void>> removePupil({required String profileId}) async {
    for (final List<PlayerIdentity> list in pupils.values) {
      list.removeWhere((PlayerIdentity pupil) => pupil.id == profileId);
    }
    return const DataSuccess<void>(null);
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
    resetPupil: ResetPupilUseCase(roster: roster),
    removePupil: RemovePupilUseCase(roster: roster),
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

/// A teacher area lock the test opens by hand.
final class OpenTeacherSession extends ChangeNotifier
    implements TeacherSessionService {
  @override
  bool isUnlocked = true;

  @override
  void lock() => isUnlocked = false;

  @override
  void unlock() => isUnlocked = true;
}

/// The pages of the class mode over [stack], the teacher area open.
ClassroomPages buildTestClassroomPages(
  FakeClassroomStack stack,
  TeacherSessionService session,
) {
  final TeacherCodeRepositoryImpl codes = TeacherCodeRepositoryImpl(
    storage: InMemoryLocalStorage(),
  );
  final TeacherCodeAttempts attempts = TeacherCodeAttempts();
  final CloseTeacherAreaUseCase closeArea = CloseTeacherAreaUseCase(
    session: session,
  );
  return ClassroomPages(
    access: TeacherAccessUseCases(
      getAccess: GetTeacherAccessUseCase(codes: codes, session: session),
      chooseCode: ChooseTeacherCodeUseCase(codes: codes, session: session),
      openArea: OpenTeacherAreaUseCase(
        codes: codes,
        lock: session,
        attempts: attempts,
        clock: MovableClock(DateTime(2026, 10, 21, 9)),
      ),
      closeArea: closeArea,
      forgetCode: ForgetTeacherCodeUseCase(codes: codes, attempts: attempts),
    ),
    list: stack.listUseCases(closeArea),
    form: stack.form,
    roster: stack.rosterUseCases,
    avatarOf: boxAvatar,
  );
}
