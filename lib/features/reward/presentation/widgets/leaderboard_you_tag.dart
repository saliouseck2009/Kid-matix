import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// "C'est toi": the dark tag that marks the active player on the
/// leaderboard, so the highlight never relies on color alone.
class LeaderboardYouTag extends StatelessWidget {
  /// Creates the tag.
  const LeaderboardYouTag({super.key});

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space8,
    vertical: 2,
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: scheme.onSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        context.l10n.leaderboardYou,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: scheme.surface),
      ),
    );
  }
}
