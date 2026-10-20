import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_progress.dart';

/// « Le devoir de la classe » on the page of a class: the unit given,
/// its day, how many pupils started it, and « Donner un devoir ».
class AssignmentCard extends StatelessWidget {
  /// Creates the card of [assignment], `null` before the first one.
  const AssignmentCard({
    required this.assignment,
    required this.pupils,
    required this.onGive,
    super.key,
  });

  /// The current assignment, or `null`.
  final AssignmentEntity? assignment;

  /// The pupils and their progress on it.
  final List<PupilProgress> pupils;

  /// Opens the choice of a unit.
  final VoidCallback onGive;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AssignmentEntity? given = assignment;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space8,
        children: <Widget>[
          Text(
            context.l10n.classroomAssignmentTitle,
            style: textTheme.titleLarge,
          ),
          if (given == null)
            Text(context.l10n.classroomAssignmentNone)
          else ...<Widget>[
            Text(
              context.l10n.unitName(given.domainId, given.unitKey),
              style: textTheme.titleMedium,
            ),
            if (given.dueAt case final DateTime due)
              Text(context.l10n.classroomAssignmentDue(due)),
            Text(
              context.l10n.classroomAssignmentStarted(
                pupils
                    .where(
                      (PupilProgress p) => (p.assignmentProgress ?? 0) > 0,
                    )
                    .length,
                pupils.length,
              ),
              style: textTheme.bodySmall?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.space4),
          DepthButton(
            label: context.l10n.classroomAssignmentGive,
            icon: Icons.assignment_rounded,
            variant: DepthButtonVariant.secondary,
            onPressed: onGive,
          ),
        ],
      ),
    );
  }
}
