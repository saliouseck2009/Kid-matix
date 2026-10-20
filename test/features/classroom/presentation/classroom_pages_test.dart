import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_transfer_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/classroom_merger.dart';
import 'package:kid_matix/features/classroom/domain/usecases/export_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/import_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_transfer_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_transfer_button.dart';
import 'package:kid_matix/features/classroom/data/repositories/teacher_code_repository_impl.dart';
import 'package:kid_matix/features/classroom/domain/usecases/close_teacher_area_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classrooms_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/pages/teacher_classrooms_page.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/pages/classroom_form_page.dart';
import 'package:kid_matix/features/classroom/presentation/pages/pupil_picker_page.dart';
import 'package:kid_matix/features/classroom/presentation/pages/teacher_classroom_page.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pupil_actions_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_item_labels.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_tile.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/pump_localized.dart';
import '../helpers/classroom_device.dart';
import '../../../helpers/in_memory_local_storage.dart';
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

  testWidgets('the teacher resets a pupil from the class page', (
    WidgetTester tester,
  ) async {
    // Arrange
    final ClassroomEntity inputClassroom = (await stack.create(
      params: const CreateClassroomParams(
        name: 'CE1',
        nicknames: <String>['Awa', 'Moussa'],
      ),
    )).requireData;
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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
    // Act
    await tester.tap(find.byTooltip('Gérer Awa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Réinitialiser sa progression'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Réinitialiser'));
    await tester.pumpAndSettle();
    // Assert
    expect(stack.roster.resetIds, hasLength(1));
    expect(
      find.text('La progression de Awa est remise à zéro.'),
      findsOneWidget,
    );
  });

  testWidgets('says when a class file is too big', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpLocalized(
      tester,
      Scaffold(
        body: BlocProvider<ClassroomTransferCubit>(
          create: (_) => ClassroomTransferCubit(
            export: ExportClassroomUseCase(
              getRoster: GetClassroomRosterUseCase(
                repository: stack.classrooms,
                roster: stack.roster,
              ),
              assignments: stack.assignments,
              journal: stack.journal,
              transfers: const _TooBigFiles(),
              clock: MovableClock(DateTime(2026, 10, 21)),
            ),
            import: ImportClassroomUseCase(
              transfers: const _TooBigFiles(),
              merger: ClassroomMerger(
                classrooms: stack.classrooms,
                roster: stack.roster,
                assignments: stack.assignments,
                journal: stack.journal,
              ),
            ),
          ),
          child: const ClassroomTransferButton(),
        ),
      ),
    );
    // Act
    await tester.tap(find.text('Recevoir une classe ou des résultats'));
    await tester.pumpAndSettle();
    // Assert
    expect(
      find.text('Ce fichier est trop gros pour cette tablette.'),
      findsOneWidget,
    );
  });

  testWidgets('« Mes classes » says when the code was changed', (
    WidgetTester tester,
  ) async {
    // Arrange
    final InMemoryLocalStorage inputStorage = InMemoryLocalStorage();
    await inputStorage.writeString(
      key: TeacherCodeRepositoryImpl.changedAtKey,
      value: DateTime(2026, 10, 21).toIso8601String(),
    );
    await pumpLocalized(
      tester,
      BlocProvider<ClassroomsCubit>(
        create: (_) => ClassroomsCubit(
          useCases: stack.listUseCases(
            CloseTeacherAreaUseCase(session: OpenTeacherSession()),
            codeStorage: inputStorage,
          ),
        )..load(),
        child: TeacherClassroomsPage(
          onOpenClassroom: (_) {},
          onCreate: () {},
          onLeave: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Code changé le 21 octobre'), findsOneWidget);
  });
}

final class _TooBigFiles implements ClassroomTransferRepository {
  const _TooBigFiles();

  @override
  Future<DataState<bool>> share({required ClassroomTransfer transfer}) async {
    return const DataSuccess<bool>(false);
  }

  @override
  Future<DataState<ClassroomTransfer?>> pick() async {
    return const DataFailed<ClassroomTransfer?>(FileTooBigException());
  }

  @override
  Future<DataState<DateTime?>> readLastExport({
    required String classroomId,
  }) async => const DataSuccess<DateTime?>(null);

  @override
  Future<DataState<void>> saveLastExport({
    required String classroomId,
    required DateTime exportedAt,
  }) async => const DataSuccess<void>(null);
}
