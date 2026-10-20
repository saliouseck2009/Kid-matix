import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/services/class_item_catalog.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_pupil_class_view_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_params.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pupil_class_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_home_banner.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/pump_localized.dart';
import '../helpers/classroom_device.dart';
import '../helpers/classroom_fakes.dart';

void main() {
  testWidgets('« J\'y vais » opens the unit of the homework', (
    WidgetTester tester,
  ) async {
    // Arrange
    final FakeClassroomStack stack = FakeClassroomStack();
    final ClassroomEntity inputClassroom = (await stack.create(
      params: const CreateClassroomParams(
        name: 'CE2',
        nicknames: <String>['Awa'],
      ),
    )).requireData;
    await stack.giveAssignment(
      params: GiveAssignmentParams(
        classroomId: inputClassroom.id,
        domainId: 'multiplication',
        unitKey: 'mul:7',
      ),
    );
    final String inputPupilId =
        stack.roster.pupils[inputClassroom.id]!.single.id;
    final List<String> actualOpened = <String>[];
    await pumpLocalized(
      tester,
      Scaffold(
        body: BlocProvider<PupilClassCubit>(
          create: (_) => PupilClassCubit(
            profileId: inputPupilId,
            getView: GetPupilClassViewUseCase(
              roster: stack.roster,
              classrooms: stack.classrooms,
              assignments: stack.assignments,
              journal: stack.journal,
              catalog: ClassItemCatalog(domains: stack.domains),
              clock: MovableClock(DateTime(2026, 10, 21, 9)),
            ),
            watchChanges: stack.overviewUseCases.watchChanges,
          )..load(),
          child: ClassHomeBanner(onOpenUnit: actualOpened.add),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Act
    await tester.tap(find.text('J\'y vais'));
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Table de 7'), findsOneWidget);
    expect(actualOpened, <String>['mul:7']);
  });
}
