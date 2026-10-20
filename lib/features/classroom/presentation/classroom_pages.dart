import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_list_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classrooms_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_access_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_access_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/pages/classroom_form_page.dart';
import 'package:kid_matix/features/classroom/presentation/pages/pupil_picker_page.dart';
import 'package:kid_matix/features/classroom/presentation/pages/teacher_access_page.dart';
import 'package:kid_matix/features/classroom/presentation/pages/teacher_classroom_page.dart';
import 'package:kid_matix/features/classroom/presentation/pages/teacher_classrooms_page.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_shelf.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_avatar_builder.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/teacher_entry_button.dart';

/// Builds the pages and slots of the class mode for the router.
///
/// Created at the composition root with the use cases resolved there, so
/// no widget ever reads the service locator.
final class ClassroomPages {
  /// Creates the factory; [avatarOf] draws the avatars of the pupils.
  const ClassroomPages({
    required this._access,
    required this._list,
    required this._form,
    required this._roster,
    required this._avatarOf,
  });

  final TeacherAccessUseCases _access;
  final ClassroomListUseCases _list;
  final ClassroomFormUseCases _form;
  final ClassroomRosterUseCases _roster;
  final PupilAvatarBuilder _avatarOf;

  /// The discreet « Espace enseignant » of « Qui joue ? ».
  Widget buildTeacherEntry({required VoidCallback onOpen}) {
    return TeacherEntryButton(onOpen: onOpen);
  }

  /// The classes at the top of « Qui joue ? ».
  Widget buildClassroomShelf({required ValueChanged<String> onOpen}) {
    return BlocProvider<ClassroomsCubit>(
      create: (_) => ClassroomsCubit(useCases: _list)..load(),
      child: ClassroomShelf(onOpenClassroom: onOpen),
    );
  }

  /// The door of the teacher area.
  Widget buildTeacherAccessPage({required VoidCallback onBack}) {
    return BlocProvider<TeacherAccessCubit>(
      create: (_) => TeacherAccessCubit(useCases: _access)..load(),
      child: TeacherAccessPage(onBack: onBack),
    );
  }

  /// « Mes classes »; [actions] go under « Nouvelle classe ».
  Widget buildTeacherClassroomsPage({
    required ValueChanged<String> onOpenClassroom,
    required VoidCallback onCreate,
    required VoidCallback onLeave,
    List<Widget> actions = const <Widget>[],
  }) {
    return BlocProvider<ClassroomsCubit>(
      create: (_) => ClassroomsCubit(useCases: _list)..load(),
      child: TeacherClassroomsPage(
        onOpenClassroom: onOpenClassroom,
        onCreate: onCreate,
        onLeave: onLeave,
        actions: actions,
      ),
    );
  }

  /// The creation of a class, or « Ajouter des élèves » to [classroomId].
  Widget buildClassroomFormPage({
    required VoidCallback onBack,
    required ValueChanged<String> onSaved,
    String? classroomId,
  }) {
    return BlocProvider<ClassroomFormCubit>(
      create: (_) =>
          ClassroomFormCubit(useCases: _form, classroomId: classroomId)..load(),
      child: ClassroomFormPage(onBack: onBack, onSaved: onSaved),
    );
  }

  /// The page of the class [classroomId] in the teacher area.
  Widget buildTeacherClassroomPage({
    required String classroomId,
    required VoidCallback onBack,
    required VoidCallback onAddPupils,
    List<Widget> sections = const <Widget>[],
  }) {
    return BlocProvider<ClassroomRosterCubit>(
      create: (_) => ClassroomRosterCubit(
        classroomId: classroomId,
        useCases: _roster,
      )..load(),
      child: TeacherClassroomPage(
        onBack: onBack,
        onAddPupils: onAddPupils,
        sections: sections,
      ),
    );
  }

  /// « Qui es-tu ? » in the class [classroomId]; [header] above the
  /// search.
  Widget buildPupilPickerPage({
    required String classroomId,
    required VoidCallback onBack,
    Widget? header,
  }) {
    return BlocProvider<ClassroomRosterCubit>(
      create: (_) => ClassroomRosterCubit(
        classroomId: classroomId,
        useCases: _roster,
      )..load(),
      child: PupilPickerPage(
        avatarOf: _avatarOf,
        onBack: onBack,
        header: header,
      ),
    );
  }
}
