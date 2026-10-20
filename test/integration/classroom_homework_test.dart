import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_class_view.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_pupil_class_view_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/select_pupil_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';

import '../helpers/in_memory_local_storage.dart';
import 'helpers/test_app.dart';

/// Owner (2026-10-20): a homework opens its unit for the pupils of the
/// class beyond their path. Over the real wiring and an on-disk
/// database: a pupil is chosen, « J'y vais » leads to the unit of the
/// homework, and its Discovery stage is played to the end.
void main() {
  late Directory databaseFolder;

  setUp(() async {
    databaseFolder = await Directory.systemTemp.createTemp('kid_matix_');
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: InMemoryLocalStorage(),
    );
  });

  tearDown(() async {
    await TestApp.stop();
    await databaseFolder.delete(recursive: true);
  });

  test('« J\'y vais » opens a playable Discovery of the homework', () async {
    // Arrange: a class of 30, the table of 7 given as homework.
    final ClassroomEntity classroom = ((await sl<CreateClassroomUseCase>()(
      params: CreateClassroomParams(
        name: 'CE2',
        nicknames: <String>[for (int i = 1; i <= 30; i++) 'Élève $i'],
      ),
    )) as DataSuccess<ClassroomEntity>).data;
    await sl<GiveAssignmentUseCase>()(
      params: GiveAssignmentParams(
        classroomId: classroom.id,
        domainId: 'multiplication',
        unitKey: 'mul:7',
      ),
    );
    final ClassroomRoster roster = ((await sl<GetClassroomRosterUseCase>()(
      params: classroom.id,
    )) as DataSuccess<ClassroomRoster>).data;
    final String pupilId = roster.pupils.first.id;
    // Act: the pupil is chosen, and « J'y vais » opens the unit of the
    // home banner.
    await sl<SelectPupilUseCase>()(params: pupilId);
    final PupilClassView banner = ((await sl<GetPupilClassViewUseCase>()(
      params: pupilId,
    )) as DataSuccess<PupilClassView?>).data!;
    final String unitKey = banner.assignment!.unitKey;
    final LearningPathEntity path = await TestApp.pathOf(pupilId);
    final QuizBloc bloc = TestApp.quizBloc();
    await TestApp.startQuiz(
      bloc,
      TestApp.stageRequest(
        profileId: pupilId,
        unitKey: unitKey,
        stage: StageKind.discovery,
      ),
    );
    final QuizState actualEnd = await TestApp.playToEnd(bloc);
    await bloc.close();
    // Assert
    final TablePathNode actualTable = path.tables.firstWhere(
      (TablePathNode table) => table.unitKey == unitKey,
    );
    expect(unitKey, 'mul:7');
    expect(actualTable.status, isNot(TableStatus.locked));
    expect(actualTable.stages.first.isUnlocked, isTrue);
    expect(path.tables[5].status, TableStatus.locked);
    expect(actualEnd, isA<QuizCompleted>());
  });
}
