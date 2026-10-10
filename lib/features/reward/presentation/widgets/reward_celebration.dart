import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/reward/domain/entities/session_rewards_entity.dart';
import 'package:kid_matix/features/reward/presentation/widgets/badge_labels.dart';

/// Shows the celebrations of [rewards] one after the other: the new level,
/// then each new badge. One tap closes each of them.
Future<void> showRewardCelebrations(
  BuildContext context, {
  required SessionRewardsEntity rewards,
  required BadgeLabels labels,
}) async {
  final List<(String, String, String)> celebrations =
      <(String, String, String)>[
        if (rewards.isLevelUp)
          (
            '',
            context.l10n.rewardLevelUpTitle(rewards.levelAfter.level),
            context.l10n.rewardLevelUpHint,
          ),
        for (final String badge in rewards.newBadges)
          (
            context.l10n.rewardBadgeUnlocked,
            labels.nameOf(badge),
            labels.hintOf(badge),
          ),
      ];
  for (final (String kicker, String title, String hint) in celebrations) {
    if (!context.mounted) return;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.rewardTapToContinue,
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 250),
      pageBuilder: (BuildContext dialogContext, _, _) => RewardCelebration(
        kicker: kicker,
        title: title,
        hint: hint,
      ),
    );
  }
}

/// One celebration: the mascot, a title and a line, closed by a tap
/// anywhere.
class RewardCelebration extends StatelessWidget {
  /// Creates the celebration.
  const RewardCelebration({
    required this.kicker,
    required this.title,
    required this.hint,
    super.key,
  });

  static const double _mascotSize = 160;

  /// Small line above the title, such as "Nouveau badge !"; may be empty.
  final String kicker;

  /// Title, such as "Niveau 5 !" or the name of the badge.
  final String title;

  /// Line under the title.
  final String hint;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Column(
              spacing: AppSizes.space16,
              children: <Widget>[
                const Spacer(),
                const MascotIllustration(
                  size: _mascotSize,
                  mood: MascotMood.happy,
                ),
                if (kicker.isNotEmpty)
                  Text(
                    kicker,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: context.palette.primaryText,
                    ),
                  ),
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall,
                  ),
                ),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
                const Spacer(),
                Text(
                  context.l10n.rewardTapToContinue,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
