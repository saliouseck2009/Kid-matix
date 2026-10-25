import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/app_pill.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessments_overview.dart';

/// « Évaluations » on the page of the assessments of a class: why, the
/// button that opens one, and each assessment with its dates and how
/// many pupils took it. No mockup: built with the design system (F31).
class AssessmentsCard extends StatelessWidget {
  /// Creates the card of [overview].
  const AssessmentsCard({
    required this.overview,
    required this.onOpen,
    required this.onClose,
    super.key,
  });

  /// The assessments of the class.
  final ClassAssessmentsOverview overview;

  /// Opens a new assessment.
  final VoidCallback onOpen;

  /// Closes the assessment given.
  final ValueChanged<ClassAssessment> onClose;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space12,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              context.l10n.classroomAssessmentsTitle,
              style: textTheme.titleLarge,
            ),
          ),
          Text(
            context.l10n.classroomAssessmentsHint,
            style: textTheme.bodyMedium?.copyWith(
              color: context.palette.mutedText,
            ),
          ),
          if (overview.assessments.isEmpty)
            Text(context.l10n.classroomAssessmentsEmpty),
          for (final AssessmentStatus status in overview.assessments)
            _AssessmentTile(
              key: ValueKey<String>(status.assessment.id),
              status: status,
              pupilCount: overview.pupilCount,
              onClose: () => onClose(status.assessment),
            ),
          DepthButton(
            label: context.l10n.classroomAssessmentNew,
            icon: Icons.flag_rounded,
            variant: DepthButtonVariant.secondary,
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile({
    required this.status,
    required this.pupilCount,
    required this.onClose,
    super.key,
  });

  final AssessmentStatus status;
  final int pupilCount;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ClassAssessment assessment = status.assessment;
    final TextStyle? muted = textTheme.bodySmall?.copyWith(
      color: context.palette.mutedText,
    );
    return Row(
      spacing: AppSizes.space8,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSizes.space4,
            children: <Widget>[
              Text(assessment.periodLabel, style: textTheme.titleMedium),
              Text(
                context.l10n.classroomAssessmentOpenedOn(assessment.openedAt),
                style: muted,
              ),
              if (assessment.closedAt case final DateTime closedAt)
                Text(
                  context.l10n.classroomAssessmentClosedOn(closedAt),
                  style: muted,
                )
              else
                AppPill(label: context.l10n.classroomAssessmentIsOpen),
              Text(
                context.l10n.classroomAssessmentTaken(
                  status.takenCount,
                  pupilCount,
                ),
                style: muted,
              ),
            ],
          ),
        ),
        if (assessment.isOpen)
          TextButton(
            onPressed: onClose,
            child: Text(context.l10n.classroomAssessmentClose),
          ),
      ],
    );
  }
}
