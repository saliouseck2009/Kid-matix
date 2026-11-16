import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// A tile of figures: a big value over a small label.
///
/// Every tile of a row is a [StatTile], so they share one padding, one
/// text size and one radius; the row stretches them to the same height
/// (see `StatTileRow`). [isHighlighted] paints the tile on the primary
/// color, for the figure that matters most.
class StatTile extends StatelessWidget {
  /// Creates a tile showing [value] over [label].
  const StatTile({
    required this.value,
    required this.label,
    this.isHighlighted = false,
    super.key,
  });

  static const double _radius = 20;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space8,
    vertical: 14,
  );

  /// Big value, such as "9 / 10".
  final String value;

  /// What the value is, such as "réussies".
  final String label;

  /// Whether the tile is on the primary color instead of white.
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color? valueColor = isHighlighted ? scheme.onPrimary : null;
    return MergeSemantics(
      child: Container(
        padding: _padding,
        decoration: BoxDecoration(
          color: isHighlighted ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: textTheme.headlineSmall?.copyWith(color: valueColor),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: isHighlighted
                    ? scheme.onPrimary
                    : context.palette.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiles side by side, all as wide and as tall as each other: a label on
/// two lines makes every tile of the row grow with it.
class StatTileRow extends StatelessWidget {
  /// Creates the row of [tiles].
  const StatTileRow({required this.tiles, super.key});

  /// The tiles, usually [StatTile]s.
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space12,
        children: <Widget>[
          for (final Widget tile in tiles) Expanded(child: tile),
        ],
      ),
    );
  }
}
