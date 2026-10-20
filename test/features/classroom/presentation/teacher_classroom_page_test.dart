import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_params.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pupil_actions_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/pages/teacher_classroom_page.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_item_labels.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/pump_localized.dart';
import '../helpers/classroom_fakes.dart';

PracticeSession _missed(String id, String pupilId, String classroomId) {
  return PracticeSession(
    id: id,
    pupilId: pupilId,
    classroomId: classroomId,
    domainId: 'multiplication',
    startedAt: DateTime(2026, 10, 20, 9),
    duration: const Duration(minutes: 4),
    questionCount: 2,
    correctCount: 0,
    answers: const <PracticeAnswer>[
      PracticeAnswer(position: 1, itemKey: 'mul:7x8', isCorrect: false),
      PracticeAnswer(position: 2, itemKey: 'mul:7x8', isCorrect: false),
    ],
  );
}

void main() {
  testWidgets('the class page shows who is stuck and on which fact', (
    WidgetTester tester,
  ) async {
    // Arrange
    final FakeClassroomStack stack = FakeClassroomStack();
    final ClassroomEntity inputClassroom = (await stack.create(
      params: const CreateClassroomParams(
        name: 'CE2',
        nicknames: <String>['Awa', 'Moussa', 'Fatou'],
      ),
    )).requireData;
    final List<PlayerIdentity> inputPupils =
        stack.roster.pupils[inputClassroom.id]!;
    await stack.giveAssignment(
      params: GiveAssignmentParams(
        classroomId: inputClassroom.id,
        domainId: 'multiplication',
        unitKey: 'mul:7',
      ),
    );
    await stack.journal.addSessions(
      sessions: <PracticeSession>[
        _missed('s1', inputPupils[0].id, inputClassroom.id),
        _missed('s2', inputPupils[1].id, inputClassroom.id),
      ],
    );
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Act
    await pumpLocalized(
      tester,
      MultiBlocProvider(
        providers: <BlocProvider<Object?>>[
          BlocProvider<ClassOverviewCubit>(
            create: (_) => ClassOverviewCubit(
              classroomId: inputClassroom.id,
              useCases: stack.overviewUseCases,
            )..load(),
          ),
          BlocProvider<PupilActionsCubit>(
            create: (_) => PupilActionsCubit(
              reset: stack.rosterUseCases.resetPupil,
              remove: stack.rosterUseCases.removePupil,
            ),
          ),
        ],
        child: TeacherClassroomPage(
          labels: ClassItemLabels(domains: stack.domains),
          avatarOf: boxAvatar,
          onBack: () {},
          onAddPupils: () {},
          onGiveAssignment: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Le devoir de la classe'), findsOneWidget);
    expect(find.text('Table de 7'), findsOneWidget);
    expect(find.text('2 élèves se trompent sur 7 × 8 = 56'), findsOneWidget);
    expect(find.text('Bloque sur : 7 × 8 = 56'), findsNWidgets(2));
    expect(find.text('N\'a pas encore joué'), findsOneWidget);
    expect(
      find.text('1 séance · 4\u00a0min · 0\u00a0% de bonnes réponses'),
      findsNWidgets(2),
    );
  });
}
