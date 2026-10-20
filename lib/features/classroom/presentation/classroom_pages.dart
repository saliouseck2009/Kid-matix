import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/assignment_form_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_work_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pupil_class_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/pages/assignment_page.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_challenge_header.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_home_banner.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_item_labels.dart';
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
    required this._work,
    required this._domains,
    required this._avatarOf,
  });

  final TeacherAccessUseCases _access;
  final ClassroomListUseCases _list;
  final ClassroomFormUseCases _form;
  final ClassroomRosterUseCases _roster;
  final ClassWorkUseCases _work;
  final DomainRegistry _domains;
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

  /// The page of the class [classroomId] in the teacher area; [actions]
  /// go at its bottom.
  Widget buildTeacherClassroomPage({
    required String classroomId,
    required VoidCallback onBack,
    required VoidCallback onAddPupils,
    required VoidCallback onGiveAssignment,
    List<Widget> actions = const <Widget>[],
  }) {
    return BlocProvider<ClassOverviewCubit>(
      create: (_) => _overviewCubit(classroomId),
      child: TeacherClassroomPage(
        labels: ClassItemLabels(domains: _domains),
        avatarOf: _avatarOf,
        onBack: onBack,
        onAddPupils: onAddPupils,
        onGiveAssignment: onGiveAssignment,
        actions: actions,
      ),
    );
  }

  /// « Donner un devoir » to the class [classroomId].
  Widget buildAssignmentPage({
    required String classroomId,
    required VoidCallback onBack,
  }) {
    return BlocProvider<AssignmentFormCubit>(
      create: (_) => AssignmentFormCubit(
        classroomId: classroomId,
        domainId: _domains.domains.first.id,
        give: _work.giveAssignment,
      ),
      child: AssignmentPage(domains: _domains, onBack: onBack),
    );
  }

  /// « Le devoir de la classe » and the class challenge at the top of the
  /// home of [profileId]; nothing for a free player.
  Widget buildHomeBanner({
    required String profileId,
    required ValueChanged<String> onOpenUnit,
  }) {
    return BlocProvider<PupilClassCubit>(
      key: ValueKey<String>('class-$profileId'),
      create: (_) => PupilClassCubit(
        profileId: profileId,
        getView: _work.getPupilView,
        watchChanges: _work.overview.watchChanges,
      )..load(),
      child: ClassHomeBanner(onOpenUnit: onOpenUnit),
    );
  }

  ClassOverviewCubit _overviewCubit(String classroomId) {
    return ClassOverviewCubit(
      classroomId: classroomId,
      useCases: _work.overview,
    )..load();
  }

  /// « Qui es-tu ? » in the class [classroomId], with the gauge of the
  /// class challenge above the search.
  Widget buildPupilPickerPage({
    required String classroomId,
    required VoidCallback onBack,
  }) {
    return BlocProvider<ClassroomRosterCubit>(
      create: (_) => ClassroomRosterCubit(
        classroomId: classroomId,
        useCases: _roster,
      )..load(),
      child: PupilPickerPage(
        avatarOf: _avatarOf,
        onBack: onBack,
        header: BlocProvider<ClassOverviewCubit>(
          create: (_) => _overviewCubit(classroomId),
          child: const ClassChallengeHeader(),
        ),
      ),
    );
  }
}
