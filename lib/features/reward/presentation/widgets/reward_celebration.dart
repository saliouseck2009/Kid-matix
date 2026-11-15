import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/game_feedback.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/services/game_feedback_service.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/reward/domain/entities/session_rewards_entity.dart';
import 'package:kid_matix/features/reward/presentation/widgets/badge_icons.dart';
import 'package:kid_matix/features/reward/presentation/widgets/badge_labels.dart';

/// A badge of the celebration: its icon, its name and how it was earned.
typedef CelebratedBadge = ({IconData icon, String name, String hint});

/// Shows the celebration of [rewards] on one screen: the new level and
/// every new badge together, with the [feedback] of a celebration. One tap
/// closes it. Shows nothing when the quiz earned neither.
Future<void> showRewardCelebration(
  BuildContext context, {
  required SessionRewardsEntity rewards,
  required BadgeLabels labels,
  required GameFeedbackService feedback,
}) async {
  if (!rewards.isLevelUp && rewards.newBadges.isEmpty) return;
  unawaited(feedback.play(GameFeedback.celebration));
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.rewardTapToContinue,
    transitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 250),
    pageBuilder: (BuildContext dialogContext, _, _) => RewardCelebration(
      level: rewards.isLevelUp ? rewards.levelAfter.level : null,
      badges: <CelebratedBadge>[
        for (final String badge in rewards.newBadges)
          (
            icon: badgeIconOf(badge),
            name: labels.nameOf(badge),
            hint: labels.hintOf(badge),
          ),
      ],
    ),
  );
}

/// The celebration of a quiz: the mascot, the new level and the new
/// badges, closed by a tap anywhere.
///
/// A level alone or a badge alone shows as a big title and a line. A
/// level with badges, or several badges, shows the title then one row per
/// badge, so the child closes one screen, not one per reward.
class RewardCelebration extends StatelessWidget {
  /// Creates the celebration of [level] and [badges]; one of them at
  /// least is given.
  const RewardCelebration({
    required this.level,
    required this.badges,
    super.key,
  });

  static const double _mascotSize = 160;

  /// Level just reached, or `null` when the level did not change.
  final int? level;

  /// Badges just unlocked; may be empty.
  final List<CelebratedBadge> badges;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int? level = this.level;
    final bool isBadgeAlone = level == null && badges.length == 1;
    final String kicker = context.l10n.rewardBadgesUnlocked(badges.length);
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
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSizes.space16,
                        children: <Widget>[
                          const Center(
                            child: MascotIllustration(
                              size: _mascotSize,
                              mood: MascotMood.happy,
                            ),
                          ),
                          if (level != null)
                            _Headline(
                              title: context.l10n.rewardLevelUpTitle(level),
                              hint: context.l10n.rewardLevelUpHint,
                            ),
                          if (isBadgeAlone)
                            _Headline(
                              kicker: kicker,
                              title: badges.single.name,
                              hint: badges.single.hint,
                            )
                          else if (badges.isNotEmpty) ...<Widget>[
                            Semantics(
                              header: true,
                              liveRegion: level == null,
                              child: Text(
                                kicker,
                                textAlign: TextAlign.center,
                                style: level == null
                                    ? textTheme.displaySmall
                                    : textTheme.titleLarge,
                              ),
                            ),
                            for (final CelebratedBadge badge in badges)
                              _BadgeRow(badge: badge),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
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

/// A big title, with a small line above and a line under.
class _Headline extends StatelessWidget {
  const _Headline({required this.title, required this.hint, this.kicker});

  final String? kicker;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? kicker = this.kicker;
    return Column(
      spacing: AppSizes.space8,
      children: <Widget>[
        if (kicker != null)
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
      ],
    );
  }
}

/// One badge of the list: its icon in a circle, its name and its line.
class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.badge});

  static const double _circle = 48;
  static const double _iconSize = 28;
  static const double _radius = 20;

  final CelebratedBadge badge;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.space12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        spacing: AppSizes.space12,
        children: <Widget>[
          Container(
            width: _circle,
            height: _circle,
            decoration: BoxDecoration(
              color: context.palette.warmTint,
              shape: BoxShape.circle,
            ),
            child: Icon(badge.icon, size: _iconSize, color: scheme.primary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(badge.name, style: textTheme.titleMedium),
                Text(
                  badge.hint,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
