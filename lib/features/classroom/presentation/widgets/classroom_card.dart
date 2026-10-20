import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/raised_card_frame.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_summary.dart';

/// Card of one class: its name and its number of pupils, tappable.
class ClassroomCard extends StatelessWidget {
  /// Creates the card of [summary].
  const ClassroomCard({required this.summary, required this.onTap, super.key});

  static const double _iconSize = 32;

  /// The class shown.
  final ClassroomSummary summary;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return RaisedCardFrame(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Row(
          spacing: AppSizes.space12,
          children: <Widget>[
            Icon(
              Icons.groups_rounded,
              size: _iconSize,
              color: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(summary.classroom.name, style: textTheme.titleLarge),
                  Text(
                    context.l10n.classroomPupilCount(summary.pupilCount),
                    style: textTheme.bodySmall?.copyWith(
                      color: context.palette.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const ExcludeSemantics(child: Icon(Icons.chevron_right_rounded)),
          ],
        ),
      ),
    );
  }
}
