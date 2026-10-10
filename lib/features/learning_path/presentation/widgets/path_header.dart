import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_pill.dart';
import 'package:kid_matix/core/widgets/crown_mark.dart';

/// Widgets of other features shown at the top of the map.
typedef PathHeaderSlots = ({
  Widget player,
  Widget streak,
  Widget dailyGoal,
});

/// Top of the map: the player, the streak and the crowns, then the daily
/// goal.
class PathHeader extends StatelessWidget {
  /// Creates the header with [slots] and the number of [crowns].
  const PathHeader({required this.slots, required this.crowns, super.key});

  /// The player, the streak and the daily goal.
  final PathHeaderSlots slots;

  /// Tables crowned so far.
  final int crowns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space16,
      children: <Widget>[
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            Expanded(flex: 3, child: slots.player),
            Flexible(flex: 2, child: slots.streak),
            Semantics(
              label: context.l10n.pathCrownsSpoken(crowns),
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space12,
                  vertical: AppPill.verticalPadding,
                ),
                decoration: BoxDecoration(
                  color: context.palette.tint,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSizes.space4,
                  children: <Widget>[
                    CrownGlyph(
                      color: Theme.of(context).colorScheme.onSurface,
                      size: AppPill.iconSize,
                    ),
                    Text(
                      '$crowns',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        slots.dailyGoal,
      ],
    );
  }
}
