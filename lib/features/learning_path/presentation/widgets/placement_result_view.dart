import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_table_tile.dart';

/// Result of the placement test (mockup 18): the tables already known,
/// now open on the path, among the 12.
class PlacementResultView extends StatelessWidget {
  /// Creates the result of [units].
  const PlacementResultView({
    required this.units,
    required this.labels,
    required this.onSeePath,
    super.key,
  });

  static const double _mascotSize = 140;

  /// Each unit of the test, with whether it was found.
  final List<({int number, bool isKnown})> units;

  /// Texts of the path.
  final PathLabels labels;

  /// Opens the path.
  final VoidCallback onSeePath;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int knownCount = units.where((unit) => unit.isKnown).length;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space16,
        children: <Widget>[
          Expanded(
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
                  Semantics(
                    header: true,
                    child: Text(
                      context.l10n.placementResultTitle(knownCount),
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall,
                    ),
                  ),
                  Text(
                    context.l10n.placementResultSubtitle(knownCount),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: context.palette.mutedText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppCard(
                    child: _TileGrid(units: units, labels: labels),
                  ),
                  const PlacementLegend(),
                ],
              ),
            ),
          ),
          DepthButton(
            label: context.l10n.placementSeePath,
            onPressed: onSeePath,
          ),
        ],
      ),
    );
  }
}

/// The tiles of the units, 4 per row.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.units, required this.labels});

  static const int _columns = 4;
  static const double _gap = 10;

  final List<({int number, bool isKnown})> units;
  final PathLabels labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: _gap,
      children: <Widget>[
        for (int start = 0; start < units.length; start += _columns)
          Row(
            spacing: _gap,
            children: <Widget>[
              for (int index = start; index < start + _columns; index++)
                Expanded(
                  child: index < units.length
                      ? PlacementTableTile(
                          key: ValueKey<int>(units[index].number),
                          mark: labels.unitMark(units[index].number),
                          name: labels.unitName(units[index].number),
                          isKnown: units[index].isKnown,
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
      ],
    );
  }
}
