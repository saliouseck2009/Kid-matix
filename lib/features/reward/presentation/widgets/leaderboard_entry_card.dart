import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_visibility_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_state.dart';

/// The card of the Profile tab that opens the weekly leaderboard; it
/// disappears while the leaderboard is hidden in the settings.
class LeaderboardEntryCard extends StatelessWidget {
  /// Creates the card; the setting comes from the enclosing Cubit.
  const LeaderboardEntryCard({required this.onOpen, super.key});

  static const double _radius = 20;
  static const double _iconBoxSize = 48;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space16,
    vertical: 14,
  );

  /// Opens the leaderboard.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final bool isShown = context.select(
      (LeaderboardVisibilityCubit cubit) => switch (cubit.state) {
        RewardValueLoaded<bool>(:final value) => value,
        _ => false,
      },
    );
    if (!isShown) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(_radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onOpen,
            child: Padding(
              padding: _padding,
              child: Row(
                spacing: AppSizes.space12,
                children: <Widget>[
                  Container(
                    width: _iconBoxSize,
                    height: _iconBoxSize,
                    decoration: BoxDecoration(
                      color: context.palette.warmTint,
                      shape: BoxShape.circle,
                    ),
                    child: ExcludeSemantics(
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: context.palette.secondaryDepth,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: <Widget>[
                        Text(
                          context.l10n.leaderboardTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          context.l10n.leaderboardEntrySubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.palette.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ExcludeSemantics(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: context.palette.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
