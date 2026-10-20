import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/pages/classroom_form_page.dart';
import 'package:kid_matix/features/classroom/presentation/pages/pupil_picker_page.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_tile.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/pump_localized.dart';
import '../helpers/classroom_fakes.dart';

void main() {
  late FakeClassroomStack stack;

  setUp(() => stack = FakeClassroomStack());

  group('« Qui es-tu ? »', () {
    Future<void> pumpPicker(WidgetTester tester, String classroomId) async {
      await pumpLocalized(
        tester,
        BlocProvider<ClassroomRosterCubit>(
          create: (_) => ClassroomRosterCubit(
            classroomId: classroomId,
            useCases: stack.rosterUseCases,
          )..load(),
          child: PupilPickerPage(avatarOf: boxAvatar, onBack: () {}),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('finds a pupil of a class of 40 by name and opens them', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ClassroomEntity inputClassroom = (await stack.create(
        params: CreateClassroomParams(
          name: 'CE1 B',
          nicknames: ClassroomRules.numberNicknames(count: 40),
        ),
      )).requireData;
      await pumpPicker(tester, inputClassroom.id);
      // Act
      await tester.enterText(find.byType(TextField), '37');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PupilTile));
      await tester.pump();
      // Assert
      expect(stack.roster.selectedId, stack.roster.pupils.values.single[36].id);
    });

    testWidgets('says when nobody matches', (WidgetTester tester) async {
      // Arrange
      final ClassroomEntity inputClassroom = (await stack.create(
        params: const CreateClassroomParams(
          name: 'CE1',
          nicknames: <String>['Awa', 'Moussa'],
        ),
      )).requireData;
      await pumpPicker(tester, inputClassroom.id);
      // Act
      await tester.enterText(find.byType(TextField), 'zz');
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(PupilTile), findsNothing);
      expect(
        find.text('Personne ne s\'appelle comme ça dans la classe.'),
        findsOneWidget,
      );
    });
  });

  group('Class creation', () {
    Future<void> pumpForm(WidgetTester tester, List<String> saved) async {
      await pumpLocalized(
        tester,
        BlocProvider<ClassroomFormCubit>(
          create: (_) => ClassroomFormCubit(useCases: stack.form)..load(),
          child: ClassroomFormPage(onBack: () {}, onSaved: saved.add),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('creates a class of 30 numbered pupils', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> actualSaved = <String>[];
      await pumpForm(tester, actualSaved);
      // Act
      await tester.enterText(find.byType(TextField).first, 'CE1 B');
      await tester.tap(find.text('Des numéros'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '30');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Créer la classe'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Créer la classe'));
      await tester.pumpAndSettle();
      // Assert
      expect(actualSaved, hasLength(1));
      expect(stack.roster.pupils[actualSaved.single], hasLength(30));
    });

    testWidgets('shows the nicknames to fix', (WidgetTester tester) async {
      // Arrange
      await pumpForm(tester, <String>[]);
      // Act
      await tester.enterText(find.byType(TextField).first, 'CE1');
      await tester.enterText(find.byType(TextField).last, 'Awa\nB\nMoussa');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Créer la classe'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Créer la classe'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.textContaining('Ces pseudos ne vont pas'), findsOneWidget);
      expect(find.textContaining(': B.'), findsOneWidget);
      expect(stack.classrooms.rows, isEmpty);
    });
  });
}
