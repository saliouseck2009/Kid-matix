import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';

/// Top of the boss fight: the quit cross, the title and the life bar of
/// the boss.
class BossHeader extends StatelessWidget {
  /// Creates the header.
  const BossHeader({
    required this.title,
    required this.boss,
    required this.onQuit,
    super.key,
  });

  /// "Boss de la table de 5".
  final String title;

  /// The boss and its hit points.
  final BossFight boss;

  /// Called by the quit cross.
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int left = boss.remainingHitPoints;
    const int total = BossFight.hitPoints;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        Row(
          spacing: AppSizes.space12,
          children: <Widget>[
            AppIconButton(
              icon: Icons.close_rounded,
              tooltip: context.l10n.quizQuitTooltip,
              onPressed: onQuit,
            ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: textTheme.titleLarge),
              ),
            ),
          ],
        ),
        ExcludeSemantics(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  context.l10n.quizBossLife,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
              ),
              Text(
                context.l10n.quizBossLifeValue(left, total),
                style: textTheme.titleMedium,
              ),
            ],
          ),
        ),
        AppProgressBar(
          value: left / total,
          semanticLabel: context.l10n.quizBossLifeSpoken(left, total),
          color: AppColors.bossLife,
        ),
      ],
    );
  }
}
