import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_class_view.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pupil_class_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_challenge_gauge.dart';

/// The top of the home of a pupil: « Le devoir de la classe » with their
/// progress and « J'y vais », and the gauge of the class challenge;
/// nothing for a free player. No mockup: built with the design system
/// (F29-11).
class ClassHomeBanner extends StatelessWidget {
  /// Creates the banner; the Cubit comes from the slot.
  const ClassHomeBanner({required this.onOpenUnit, super.key});

  static const int _percent = 100;

  /// Opens the assigned unit.
  final ValueChanged<String> onOpenUnit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PupilClassCubit, PupilClassView?>(
      builder: (BuildContext context, PupilClassView? view) {
        if (view == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.space16,
            AppSizes.space8,
            AppSizes.space16,
            0,
          ),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSizes.space12,
              children: <Widget>[
                if (view.assignment case final AssignmentEntity assignment)
                  _AssignmentPart(
                    assignment: assignment,
                    percent: ((view.assignmentProgress ?? 0) * _percent)
                        .round(),
                    onOpen: () => onOpenUnit(assignment.unitKey),
                  ),
                ClassChallengeGauge(challenge: view.challenge),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AssignmentPart extends StatelessWidget {
  const _AssignmentPart({
    required this.assignment,
    required this.percent,
    required this.onOpen,
  });

  static const double _percentBase = 100;

  final AssignmentEntity assignment;
  final int percent;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String learned = context.l10n.classroomAssignmentLearned(percent);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space8,
      children: <Widget>[
        Text(
          context.l10n.classroomAssignmentTitle,
          style: textTheme.labelLarge,
        ),
        Text(
          context.l10n.unitName(assignment.domainId, assignment.unitKey),
          style: textTheme.titleLarge,
        ),
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            Expanded(
              child: AppProgressBar(
                value: percent / _percentBase,
                semanticLabel: learned,
              ),
            ),
            ExcludeSemantics(child: Text(learned, style: textTheme.bodySmall)),
          ],
        ),
        DepthButton(
          label: context.l10n.classroomAssignmentPlay,
          icon: Icons.play_arrow_rounded,
          onPressed: onOpen,
        ),
      ],
    );
  }
}
