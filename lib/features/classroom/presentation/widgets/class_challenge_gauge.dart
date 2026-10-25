import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_challenge.dart';

/// The gauge of the class challenge: right answers of the whole class
/// this week towards the shared goal, with no individual ranking.
class ClassChallengeGauge extends StatelessWidget {
  /// Creates the gauge of [challenge].
  const ClassChallengeGauge({required this.challenge, super.key});

  /// The challenge of the week.
  final ClassChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String line = challenge.isReached
        ? context.l10n.classroomChallengeReached
        : context.l10n.classroomChallengeProgress(
            challenge.correctCount,
            challenge.goal,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space8,
      children: <Widget>[
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            Icon(
              Icons.emoji_events_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              child: Text(
                context.l10n.classroomChallengeTitle,
                style: textTheme.titleMedium,
              ),
            ),
          ],
        ),
        AppProgressBar(value: challenge.progress, semanticLabel: line),
        ExcludeSemantics(child: Text(line, style: textTheme.bodySmall)),
      ],
    );
  }
}
