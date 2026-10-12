import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// One table of the placement test result: violet with a yellow check
/// when already known, light when still to discover.
class PlacementTableTile extends StatelessWidget {
  /// Creates the tile of the table marked [mark], such as "×7".
  const PlacementTableTile({
    required this.mark,
    required this.name,
    required this.isKnown,
    super.key,
  });

  static const double _height = 72;
  static const double _fontSize = 24;
  static const double _checkSize = 20;

  /// Short mark shown, such as "×7".
  final String mark;

  /// Name read by a screen reader, such as "Table de 7".
  final String name;

  /// Whether the player already knows the table.
  final bool isKnown;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color foreground = isKnown
        ? colors.onPrimary
        : context.palette.mutedText;
    return Semantics(
      label: isKnown
          ? context.l10n.placementTableKnown(name)
          : context.l10n.placementTableToDiscover(name),
      excludeSemantics: true,
      child: Container(
        height: _height,
        decoration: BoxDecoration(
          color: isKnown ? colors.primary : context.palette.lockedFace,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        padding: const EdgeInsets.all(AppSizes.space4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                mark,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: _fontSize,
                  color: foreground,
                ),
              ),
              if (isKnown)
                Icon(
                  Icons.check_rounded,
                  size: _checkSize,
                  color: colors.secondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Legend of the tiles: « Déjà connue » and « À découvrir ».
class PlacementLegend extends StatelessWidget {
  /// Creates the legend.
  const PlacementLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: AppSizes.space8,
        children: <Widget>[
          _LegendItem(
            color: Theme.of(context).colorScheme.primary,
            label: context.l10n.placementLegendKnown,
          ),
          _LegendItem(
            color: context.palette.lockedFace,
            label: context.l10n.placementLegendToDiscover,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  static const double _swatchSize = 14;
  static const double _swatchRadius = 5;

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: <Widget>[
        Container(
          width: _swatchSize,
          height: _swatchSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_swatchRadius),
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: context.palette.mutedText,
          ),
        ),
      ],
    );
  }
}
