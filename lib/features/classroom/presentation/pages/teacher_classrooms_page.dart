import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_summary.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classrooms_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classrooms_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_card.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';

/// « Mes classes », the home of the teacher area: the classes of the
/// device and « Nouvelle classe ». No mockup: built with the design
/// system (F29-11).
class TeacherClassroomsPage extends StatelessWidget {
  /// Creates the page; the Cubit comes from the route.
  const TeacherClassroomsPage({
    required this.onOpenClassroom,
    required this.onCreate,
    required this.onLeave,
    this.actions = const <Widget>[],
    super.key,
  });

  /// Opens the page of a class.
  final ValueChanged<String> onOpenClassroom;

  /// Opens the creation of a class.
  final VoidCallback onCreate;

  /// Goes back to « Qui joue ? » once the area is closed.
  final VoidCallback onLeave;

  /// Buttons of other parts of the area under « Nouvelle classe », such
  /// as the import of results.
  final List<Widget> actions;

  Future<void> _leave(BuildContext context) async {
    await context.read<ClassroomsCubit>().leaveTeacherArea();
    onLeave();
  }

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: () => _leave(context),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ClassroomsCubit, ClassroomsState>(
            builder: (BuildContext context, ClassroomsState state) {
              return ListView(
                padding: const EdgeInsets.all(AppSizes.space24),
                children: <Widget>[
                  ClassroomPageHeader(
                    title: context.l10n.classroomListTitle,
                    subtitle: switch (state) {
                      ClassroomsLoaded(:final DateTime codeChangedAt) =>
                        context.l10n.classroomCodeChanged(codeChangedAt),
                      _ => null,
                    },
                    backIcon: Icons.logout_rounded,
                    backTooltip: context.l10n.classroomLeaveArea,
                    onBack: () => _leave(context),
                  ),
                  const SizedBox(height: AppSizes.space24),
                  _ClassroomList(state: state, onOpen: onOpenClassroom),
                  const SizedBox(height: AppSizes.space24),
                  DepthButton(
                    label: context.l10n.classroomNew,
                    icon: Icons.add_rounded,
                    onPressed: onCreate,
                  ),
                  for (final Widget action in actions) ...<Widget>[
                    const SizedBox(height: AppSizes.space16),
                    action,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The classes of « Mes classes », or why there is none.
class _ClassroomList extends StatelessWidget {
  const _ClassroomList({required this.state, required this.onOpen});

  final ClassroomsState state;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ClassroomsLoading() => const Center(child: CircularProgressIndicator()),
      ClassroomsFailure() => Text(context.l10n.classroomErrorGeneric),
      ClassroomsLoaded(:final classrooms) when classrooms.isEmpty => Text(
        context.l10n.classroomListEmpty,
      ),
      ClassroomsLoaded(:final classrooms) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space12,
        children: <Widget>[
          for (final ClassroomSummary summary in classrooms)
            ClassroomCard(
              key: ValueKey<String>(summary.classroom.id),
              summary: summary,
              onTap: () => onOpen(summary.classroom.id),
            ),
        ],
      ),
    };
  }
}
