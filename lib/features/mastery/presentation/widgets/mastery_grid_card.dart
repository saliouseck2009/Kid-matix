import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_mastery_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_grid_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_status.dart';
import 'package:kid_matix/features/mastery/presentation/widgets/mastery_status_style.dart';

/// "Mes tables": one row per table, one cell per fact colored by its
/// status, and the legend; a screen reader reads each fact with its
/// status.
class MasteryGridCard extends StatelessWidget {
  /// Creates the card of [grid] in [domain].
  const MasteryGridCard({required this.grid, required this.domain, super.key});

  static const double _radius = 20;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space16,
    vertical: 14,
  );

  /// Status of every fact.
  final MasteryGridEntity grid;

  /// Domain of the facts, to name the rows, columns and facts.
  final LearningDomain domain;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              context.l10n.masteryGridTitle,
              style: textTheme.titleMedium,
            ),
          ),
          _Grid(grid: grid, domain: domain),
          const _Legend(),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.grid, required this.domain});

  static const double _labelWidth = 26;
  static const double _gap = 3;

  final MasteryGridEntity grid;
  final LearningDomain domain;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelMedium
        ?.copyWith(fontSize: 12, color: context.palette.mutedText);
    final int columns = grid.rows.values.fold(
      0,
      (int most, List<ItemMasteryEntity> row) =>
          row.length > most ? row.length : most,
    );
    return Column(
      spacing: _gap,
      children: <Widget>[
        ExcludeSemantics(
          child: Row(
            spacing: _gap,
            children: <Widget>[
              const SizedBox(width: _labelWidth),
              for (int column = 1; column <= columns; column++)
                Expanded(
                  child: FittedBox(
                    child: Text('×$column', style: labelStyle),
                  ),
                ),
            ],
          ),
        ),
        for (final MapEntry<String, List<ItemMasteryEntity>> row
            in grid.rows.entries)
          Row(
            spacing: _gap,
            children: <Widget>[
              SizedBox(
                width: _labelWidth,
                child: ExcludeSemantics(
                  child: Text(
                    '${domain.findUnit(row.key)?.number ?? ''}',
                    style: labelStyle,
                  ),
                ),
              ),
              for (final ItemMasteryEntity cell in row.value)
                Expanded(
                  child: _Cell(cell: cell, domain: domain),
                ),
              for (int empty = row.value.length; empty < columns; empty++)
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.cell, required this.domain});

  static const double _height = 18;
  static const double _radius = 5;

  final ItemMasteryEntity cell;
  final LearningDomain domain;

  @override
  Widget build(BuildContext context) {
    final LearningItem? item = domain.findItem(cell.itemKey);
    final String fact = item == null
        ? ''
        : domain.describeItem(item).toSpokenText(context.l10n);
    return Semantics(
      label: context.l10n.masteryCellSpoken(
        fact,
        cell.status.nameIn(context.l10n),
      ),
      child: Container(
        height: _height,
        decoration: BoxDecoration(
          color: cell.status.color,
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  static const double _swatch = 12;
  static const double _swatchRadius = 4;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: context.palette.mutedText);
    return ExcludeSemantics(
      child: Wrap(
        spacing: AppSizes.space12,
        runSpacing: 6,
        children: <Widget>[
          for (final MasteryStatus status in MasteryStatus.values)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: <Widget>[
                Container(
                  width: _swatch,
                  height: _swatch,
                  decoration: BoxDecoration(
                    color: status.color,
                    borderRadius: BorderRadius.circular(_swatchRadius),
                  ),
                ),
                Text(status.nameIn(context.l10n), style: style),
              ],
            ),
        ],
      ),
    );
  }
}
