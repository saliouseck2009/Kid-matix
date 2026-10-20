import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_overview.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_progress.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/assignment_card.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_challenge_card.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_item_labels.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/level_groups_card.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_avatar_builder.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_progress_tile.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/struggles_card.dart';

/// The page of a class in the teacher area: « Le devoir de la classe »,
/// the class challenge, who is stuck and on what, the level groups, and
/// the dashboard of each pupil. No mockup: built with the design system
/// (F29-11).
class TeacherClassroomPage extends StatelessWidget {
  /// Creates the page; the Cubit comes from the route.
  const TeacherClassroomPage({
    required this.labels,
    required this.avatarOf,
    required this.onBack,
    required this.onAddPupils,
    required this.onGiveAssignment,
    this.actions = const <Widget>[],
    super.key,
  });

  /// Writes the items.
  final ClassItemLabels labels;

  /// Draws the avatars.
  final PupilAvatarBuilder avatarOf;

  /// Goes back to « Mes classes ».
  final VoidCallback onBack;

  /// Opens « Ajouter des élèves ».
  final VoidCallback onAddPupils;

  /// Opens the choice of the assignment.
  final VoidCallback onGiveAssignment;

  /// Buttons at the bottom of the page, such as the transfer of results.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ClassOverviewCubit, ClassOverviewState>(
            builder: (BuildContext context, ClassOverviewState state) {
              return switch (state) {
                ClassOverviewLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ClassOverviewFailure() => Center(
                  child: Text(context.l10n.classroomErrorGeneric),
                ),
                ClassOverviewLoaded(:final overview) => _OverviewView(
                  overview: overview,
                  page: this,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _OverviewView extends StatelessWidget {
  const _OverviewView({required this.overview, required this.page});

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space24,
  );

  final ClassOverview overview;
  final TeacherClassroomPage page;

  @override
  Widget build(BuildContext context) {
    final List<PupilProgress> pupils = overview.dashboard.pupils;
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(AppSizes.space24),
          sliver: SliverList.list(children: _cards(context)),
        ),
        SliverPadding(
          padding: _padding,
          sliver: SliverList.separated(
            itemCount: pupils.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: AppSizes.space8),
            itemBuilder: (BuildContext context, int index) => PupilProgressTile(
              key: ValueKey<String>(pupils[index].pupil.id),
              progress: pupils[index],
              labels: page.labels,
              avatarOf: page.avatarOf,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSizes.space24),
          sliver: SliverList.list(children: _actions(context)),
        ),
      ],
    );
  }

  List<Widget> _cards(BuildContext context) {
    final ClassOverviewCubit cubit = context.read<ClassOverviewCubit>();
    const SizedBox gap = SizedBox(height: AppSizes.space16);
    return <Widget>[
      ClassroomPageHeader(
        title: overview.roster.classroom.name,
        subtitle: context.l10n.classroomPupilCount(
          overview.roster.pupils.length,
        ),
        onBack: page.onBack,
      ),
      gap,
      AssignmentCard(
        assignment: overview.assignment,
        pupils: overview.dashboard.pupils,
        onGive: page.onGiveAssignment,
      ),
      gap,
      ClassChallengeCard(
        challenge: overview.challenge,
        onGoalChanged: cubit.setWeeklyGoal,
      ),
      gap,
      StrugglesCard(
        struggles: overview.dashboard.struggles,
        labels: page.labels,
      ),
      gap,
      LevelGroupsCard(
        groups: overview.groups,
        domainId: overview.groupsDomainId,
      ),
      gap,
      Semantics(
        header: true,
        child: Text(
          context.l10n.classroomPupilsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      if (overview.roster.pupils.isEmpty)
        Text(context.l10n.classroomPickerEmpty),
    ];
  }

  List<Widget> _actions(BuildContext context) {
    return <Widget>[
      DepthButton(
        label: context.l10n.classroomAddPupils,
        icon: Icons.person_add_alt_1_rounded,
        variant: DepthButtonVariant.secondary,
        onPressed: page.onAddPupils,
      ),
      for (final Widget action in page.actions) ...<Widget>[
        const SizedBox(height: AppSizes.space16),
        action,
      ],
    ];
  }
}
