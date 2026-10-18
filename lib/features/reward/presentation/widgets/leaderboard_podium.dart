import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_avatar_builder.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_crown.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_spoken.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_you_tag.dart';

/// The three first players on a podium (mockup 19): the first in the
/// middle under a crown, the second on the left, the third on the right.
class LeaderboardPodium extends StatelessWidget {
  /// Creates the podium of the first [entries], at most three.
  const LeaderboardPodium({
    required this.entries,
    required this.activeProfileId,
    required this.avatarOf,
    super.key,
  });

  /// Number of players on the podium.
  static const int size = 3;

  /// Ranks from left to right.
  static const List<int> _ranksInOrder = <int>[2, 1, 3];

  static const double _radius = 24;
  static const double _gap = 10;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSizes.space16,
    20,
    AppSizes.space16,
    0,
  );

  /// The first players, first one first.
  final List<LeaderboardEntry> entries;

  /// The player looking at the screen.
  final String activeProfileId;

  /// Draws the avatars.
  final LeaderboardAvatarBuilder avatarOf;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: _gap,
        children: <Widget>[
          for (final int rank in _ranksInOrder)
            Expanded(
              child: rank <= entries.length
                  ? _PodiumStep(
                      entry: entries[rank - 1],
                      rank: rank,
                      isActive: entries[rank - 1].player.id == activeProfileId,
                      avatarOf: avatarOf,
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

/// How a step of the podium looks.
typedef _StepLook = ({
  double height,
  double avatarSize,
  Color color,
  TextStyle? rankStyle,
});

class _PodiumStep extends StatelessWidget {
  const _PodiumStep({
    required this.entry,
    required this.rank,
    required this.isActive,
    required this.avatarOf,
  });

  static const double _radius = 16;
  static const double _firstAvatarSize = 72;
  static const double _avatarSize = 60;
  static const double _crownSize = 30;

  final LeaderboardEntry entry;
  final int rank;
  final bool isActive;
  final LeaderboardAvatarBuilder avatarOf;

  _StepLook _lookOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return switch (rank) {
      1 => (
        height: 156,
        avatarSize: _firstAvatarSize,
        color: theme.colorScheme.secondary,
        rankStyle: theme.textTheme.displaySmall,
      ),
      2 => (
        height: 112,
        avatarSize: _avatarSize,
        color: context.palette.strongBorder,
        rankStyle: theme.textTheme.headlineMedium,
      ),
      _ => (
        height: 80,
        avatarSize: _avatarSize,
        color: context.palette.lockedFace,
        rankStyle: theme.textTheme.headlineMedium,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _StepLook look = _lookOf(context);
    return Semantics(
      container: true,
      label: describeLeaderboardEntry(
        context.l10n,
        entry: entry,
        rank: rank,
        isActive: isActive,
      ),
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSizes.space4,
        children: <Widget>[
          if (rank == 1) const LeaderboardCrown(size: _crownSize),
          avatarOf(entry.player, look.avatarSize),
          Text(
            entry.player.nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          if (isActive) const LeaderboardYouTag(),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: look.height),
            padding: const EdgeInsets.only(
              top: 10,
              bottom: AppSizes.space8,
            ),
            decoration: BoxDecoration(
              color: look.color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(_radius),
              ),
            ),
            child: Column(
              children: <Widget>[
                Text('$rank', style: look.rankStyle),
                Text(
                  context.l10n.leaderboardXp(entry.weeklyXp),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
