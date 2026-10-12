import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_avatar_builder.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_spoken.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_you_tag.dart';

/// A player ranked under the podium (mockup 19): rank, avatar, nickname
/// and XP of the week on a white card; the active player is framed and
/// tagged.
class LeaderboardRow extends StatelessWidget {
  /// Creates the row of [entry], ranked [rank].
  const LeaderboardRow({
    required this.entry,
    required this.rank,
    required this.isActive,
    required this.avatarOf,
    super.key,
  });

  static const double _minHeight = 68;
  static const double _radius = 20;
  static const double _rankWidth = 28;
  static const double _avatarSize = 44;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space16,
    vertical: 10,
  );

  /// The player and their XP.
  final LeaderboardEntry entry;

  /// Rank, from 1.
  final int rank;

  /// Whether it is the player looking at the screen.
  final bool isActive;

  /// Draws the avatar.
  final LeaderboardAvatarBuilder avatarOf;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = context.palette.mutedText;
    return Semantics(
      container: true,
      label: describeLeaderboardEntry(
        context.l10n,
        entry: entry,
        rank: rank,
        isActive: isActive,
      ),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: _minHeight),
        padding: _padding,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(_radius),
          border: isActive
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: AppSizes.borderWidth,
                )
              : null,
        ),
        child: Row(
          spacing: AppSizes.space12,
          children: <Widget>[
            SizedBox(
              width: _rankWidth,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(color: muted),
              ),
            ),
            avatarOf(entry.player, _avatarSize),
            Expanded(
              child: Wrap(
                spacing: AppSizes.space8,
                runSpacing: AppSizes.space4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    entry.player.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (isActive) const LeaderboardYouTag(),
                ],
              ),
            ),
            Text(
              context.l10n.leaderboardXp(entry.weeklyXp),
              style: theme.textTheme.labelLarge?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
