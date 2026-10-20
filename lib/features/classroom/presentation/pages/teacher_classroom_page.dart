import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_pupils_card.dart';

/// The page of a class in the teacher area: its pupils, « Ajouter des
/// élèves », and the sections of the other parts of the class mode
/// (assignment, dashboard, groups, challenge, transfer). No mockup:
/// built with the design system (F29-11).
class TeacherClassroomPage extends StatelessWidget {
  /// Creates the page; the Cubit comes from the route.
  const TeacherClassroomPage({
    required this.onBack,
    required this.onAddPupils,
    this.sections = const <Widget>[],
    super.key,
  });

  /// Goes back to « Mes classes ».
  final VoidCallback onBack;

  /// Opens « Ajouter des élèves ».
  final VoidCallback onAddPupils;

  /// Sections shown between the header and the pupils.
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ClassroomRosterCubit, ClassroomRosterState>(
            builder: (BuildContext context, ClassroomRosterState state) {
              return switch (state) {
                ClassroomRosterLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ClassroomRosterFailure() => Center(
                  child: Text(context.l10n.classroomErrorGeneric),
                ),
                ClassroomRosterLoaded(:final roster) => _ClassroomView(
                  roster: roster,
                  onBack: onBack,
                  onAddPupils: onAddPupils,
                  sections: sections,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _ClassroomView extends StatelessWidget {
  const _ClassroomView({
    required this.roster,
    required this.onBack,
    required this.onAddPupils,
    required this.sections,
  });

  final ClassroomRoster roster;
  final VoidCallback onBack;
  final VoidCallback onAddPupils;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.space24),
      children: <Widget>[
        ClassroomPageHeader(
          title: roster.classroom.name,
          subtitle: context.l10n.classroomPupilCount(roster.pupils.length),
          onBack: onBack,
        ),
        for (final Widget section in sections) ...<Widget>[
          const SizedBox(height: AppSizes.space16),
          section,
        ],
        const SizedBox(height: AppSizes.space16),
        ClassroomPupilsCard(pupils: roster.pupils),
        const SizedBox(height: AppSizes.space16),
        DepthButton(
          label: context.l10n.classroomAddPupils,
          icon: Icons.person_add_alt_1_rounded,
          variant: DepthButtonVariant.secondary,
          onPressed: onAddPupils,
        ),
      ],
    );
  }
}
