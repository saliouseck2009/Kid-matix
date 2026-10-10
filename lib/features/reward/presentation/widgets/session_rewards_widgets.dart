import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/features/reward/domain/entities/player_level.dart';
import 'package:kid_matix/features/reward/domain/entities/session_rewards_entity.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_state.dart';
import 'package:kid_matix/features/reward/presentation/widgets/badge_labels.dart';

/// Cubit of the rewards of the quiz shown by the results.
typedef SessionRewardsCubit = RewardValueCubit<SessionRewardsEntity?>;

/// The rewards of the quiz once read, or `null`.
SessionRewardsEntity? _rewardsOf(BuildContext context) {
  return switch (context.watch<SessionRewardsCubit>().state) {
    RewardValueLoaded<SessionRewardsEntity?>(:final value) => value,
    _ => null,
  };
}

/// First tile of the results: the XP earned, on the primary color.
class SessionXpTile extends StatelessWidget {
  /// Creates the tile.
  const SessionXpTile({super.key});

  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    final SessionRewardsEntity? rewards = _rewardsOf(context);
    if (rewards == null) return const SizedBox.shrink();
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        spacing: 2,
        children: <Widget>[
          FittedBox(
            child: Text(
              context.l10n.rewardXpEarned(rewards.xpEarned),
              style: textTheme.headlineSmall?.copyWith(color: scheme.onPrimary),
            ),
          ),
          Text(
            context.l10n.rewardXpEarnedLabel,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: scheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

/// Card of the level after the quiz and the XP to the next one, then the
/// badges the quiz unlocked.
class SessionLevelCard extends StatelessWidget {
  /// Creates the card; [labels] name the badges.
  const SessionLevelCard({required this.labels, super.key});

  /// Names of the badges.
  final BadgeLabels labels;

  @override
  Widget build(BuildContext context) {
    final SessionRewardsEntity? rewards = _rewardsOf(context);
    if (rewards == null) return const SizedBox.shrink();
    final PlayerLevel level = rewards.levelAfter;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space16,
      children: <Widget>[
        _WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSizes.space8,
            children: <Widget>[
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSizes.space8,
                children: <Widget>[
                  Text(
                    context.l10n.rewardLevel(level.level),
                    style: textTheme.titleMedium,
                  ),
                  Text(
                    context.l10n.rewardXpToNextLevel(
                      level.xpToNextLevel,
                      level.level + 1,
                    ),
                    style: textTheme.bodySmall?.copyWith(
                      color: context.palette.mutedText,
                    ),
                  ),
                ],
              ),
              AppProgressBar(
                value: level.progress.clamp(0, 1),
                semanticLabel: context.l10n.rewardLevelProgressSpoken(
                  level.level + 1,
                ),
              ),
            ],
          ),
        ),
        if (rewards.newBadges.isNotEmpty)
          _WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSizes.space8,
              children: <Widget>[
                Text(
                  context.l10n.rewardNewBadgesTitle(rewards.newBadges.length),
                  style: textTheme.titleMedium,
                ),
                for (final String badge in rewards.newBadges)
                  Row(
                    spacing: AppSizes.space8,
                    children: <Widget>[
                      Icon(
                        Icons.military_tech_rounded,
                        color: context.palette.secondaryDepth,
                      ),
                      Expanded(
                        child: Text(
                          labels.nameOf(badge),
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  static const double _radius = 20;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: child,
    );
  }
}
