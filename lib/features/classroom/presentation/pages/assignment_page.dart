import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/choice_segments.dart';
import 'package:kid_matix/core/widgets/raised_card_frame.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/assignment_form_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/assignment_form_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';

/// « Donner un devoir »: the teacher picks a domain, a due day and a
/// unit of its path, which becomes « Le devoir de la classe ». No
/// mockup: built with the design system (F29-11).
class AssignmentPage extends StatelessWidget {
  /// Creates the page; the Cubit comes from the route.
  const AssignmentPage({
    required this.domains,
    required this.onBack,
    super.key,
  });

  /// The learning domains of the app.
  final DomainRegistry domains;

  /// Goes back to the page of the class, also once the unit is given.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<AssignmentFormCubit, AssignmentFormState>(
            listenWhen: (
              AssignmentFormState previous,
              AssignmentFormState next,
            ) => next.isGiven,
            listener: (BuildContext context, AssignmentFormState state) =>
                onBack(),
            builder: (BuildContext context, AssignmentFormState state) {
              return _AssignmentView(
                state: state,
                domains: domains,
                onBack: onBack,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AssignmentView extends StatelessWidget {
  const _AssignmentView({
    required this.state,
    required this.domains,
    required this.onBack,
  });

  final AssignmentFormState state;
  final DomainRegistry domains;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final AssignmentFormCubit cubit = context.read<AssignmentFormCubit>();
    final List<LearningUnit> units =
        domains.find(state.domainId)?.path ?? const <LearningUnit>[];
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(AppSizes.space24),
          sliver: SliverList.list(
            children: <Widget>[
              ClassroomPageHeader(
                title: context.l10n.classroomAssignmentGive,
                subtitle: context.l10n.classroomAssignmentPickHint,
                onBack: onBack,
              ),
              const SizedBox(height: AppSizes.space16),
              ChoiceSegments<String>(
                choices: <String>[
                  for (final LearningDomain domain in domains.domains)
                    domain.id,
                ],
                selected: state.domainId,
                isScrollable: true,
                labelOf: context.l10n.domainName,
                semanticLabelOf: context.l10n.domainSpokenName,
                onSelected: cubit.selectDomain,
              ),
              const SizedBox(height: AppSizes.space12),
              ChoiceSegments<AssignmentDue>(
                choices: AssignmentDue.values,
                selected: state.due,
                labelOf: (AssignmentDue due) => switch (due) {
                  AssignmentDue.none => context.l10n.classroomAssignmentDueNone,
                  AssignmentDue.tomorrow =>
                    context.l10n.classroomAssignmentDueTomorrow,
                  AssignmentDue.nextWeek =>
                    context.l10n.classroomAssignmentDueWeek,
                },
                onSelected: cubit.selectDue,
              ),
              if (state.errorCode != null)
                Semantics(
                  liveRegion: true,
                  child: Text(context.l10n.classroomErrorGeneric),
                ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.space24,
            0,
            AppSizes.space24,
            AppSizes.space24,
          ),
          sliver: SliverList.separated(
            itemCount: units.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: AppSizes.space8),
            itemBuilder: (BuildContext context, int index) => _UnitTile(
              key: ValueKey<String>(units[index].key),
              name: context.l10n.unitName(state.domainId, units[index].key),
              onTap: state.isSaving ? null : () => cubit.give(units[index].key),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.name, required this.onTap, super.key});

  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RaisedCardFrame(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Text(name, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
