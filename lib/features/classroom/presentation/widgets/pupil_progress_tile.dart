import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_progress.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_item_labels.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_avatar_builder.dart';

/// One pupil on the dashboard of a class: practice, last session,
/// progress on the assignment and the items they are stuck on.
class PupilProgressTile extends StatelessWidget {
  /// Creates the tile of [progress].
  const PupilProgressTile({
    required this.progress,
    required this.labels,
    required this.avatarOf,
    super.key,
  });

  static const double _avatarSize = 40;
  static const int _percent = 100;

  /// The pupil and their figures.
  final PupilProgress progress;

  /// Writes the items.
  final ClassItemLabels labels;

  /// Draws the avatar.
  final PupilAvatarBuilder avatarOf;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? muted = textTheme.bodySmall?.copyWith(
      color: context.palette.mutedText,
    );
    return AppCard(
      padding: const EdgeInsets.all(AppSizes.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.space12,
        children: <Widget>[
          ExcludeSemantics(child: avatarOf(progress.pupil.player, _avatarSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSizes.space4,
              children: <Widget>[
                Text(progress.pupil.nickname, style: textTheme.titleMedium),
                ..._practiceLines(context, muted),
                if (progress.assignmentProgress case final double share)
                  _AssignmentLine(share: share),
                if (progress.struggleItemKeys.isNotEmpty)
                  Text(
                    context.l10n.classroomPupilStuckOn(
                      labels.describeAll(progress.struggleItemKeys),
                    ),
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _practiceLines(BuildContext context, TextStyle? style) {
    final DateTime? last = progress.lastPlayedAt;
    if (!progress.hasPlayed || last == null) {
      return <Widget>[
        Text(context.l10n.classroomPupilNeverPlayed, style: style),
      ];
    }
    final int answers = progress.answerCount;
    return <Widget>[
      Text(
        context.l10n.classroomPupilSummary(
          progress.sessionCount,
          progress.practiceTime.inMinutes,
          answers == 0 ? 0 : progress.correctCount * _percent ~/ answers,
        ),
        style: style,
      ),
      Text(context.l10n.classroomPupilLastSession(last), style: style),
    ];
  }
}

class _AssignmentLine extends StatelessWidget {
  const _AssignmentLine({required this.share});

  static const int _percent = 100;

  final double share;

  @override
  Widget build(BuildContext context) {
    final String label = context.l10n.classroomAssignmentLearned(
      (share * _percent).round(),
    );
    return Row(
      spacing: AppSizes.space8,
      children: <Widget>[
        Expanded(
          child: AppProgressBar(value: share, semanticLabel: label),
        ),
        ExcludeSemantics(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
