import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/widgets/help_audio_button.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_mastery_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_grid_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_status.dart';
import 'package:kid_matix/features/mastery/presentation/widgets/mastery_status_style.dart';

/// "Mes tables": one row per table, one cell per fact colored by its
/// status, and the legend; a screen reader reads each fact with its
/// status.
///
/// For a domain with recordings (the math words), a cell can be touched: its
/// word shows under the grid with its « Écouter en wolof » button.
class MasteryGridCard extends StatefulWidget {
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
  State<MasteryGridCard> createState() => _MasteryGridCardState();
}

class _MasteryGridCardState extends State<MasteryGridCard> {
  LearningItem? _touched;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final LearningDomain domain = widget.domain;
    final LearningItem? touched = _touched;
    final String? recordingKey = touched == null
        ? null
        : domain.recordingKeyOf(touched);
    return Container(
      padding: MasteryGridCard._padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(MasteryGridCard._radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: <Widget>[
          Semantics(
            header: true,
            label: context.l10n.gridSpokenTitle(domain.id),
            excludeSemantics: true,
            child: Text(
              context.l10n.gridTitle(domain.id),
              style: textTheme.titleMedium,
            ),
          ),
          _Grid(
            grid: widget.grid,
            domain: domain,
            onTouch: (LearningItem item) => setState(() => _touched = item),
          ),
          if (touched != null && recordingKey != null)
            Row(
              spacing: AppSizes.space8,
              children: <Widget>[
                Expanded(
                  child: Text(
                    domain.describeItem(touched).toDisplayText(),
                    style: textTheme.titleMedium,
                  ),
                ),
                HelpAudioButton(
                  key: ValueKey<String>(recordingKey),
                  wordKey: recordingKey,
                ),
              ],
            ),
          const _Legend(),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.grid,
    required this.domain,
    required this.onTouch,
  });

  static const double _labelWidth = 26;
  static const double _gap = 3;

  final MasteryGridEntity grid;
  final LearningDomain domain;
  final ValueChanged<LearningItem> onTouch;

  /// Mark of the row of [unitKey]: the number of a table, the short mark
  /// of a unit of another domain, such as "<>".
  String _rowLabel(
    BuildContext context,
    String unitKey,
    bool isMultiplication,
  ) {
    final int? number = domain.findUnit(unitKey)?.number;
    if (number == null) return '';
    return isMultiplication
        ? '$number'
        : context.l10n.unitMark(domain.id, unitKey);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelMedium
        ?.copyWith(fontSize: 12, color: context.palette.mutedText);
    final int columns = grid.rows.values.fold(
      0,
      (int most, List<ItemMasteryEntity> row) =>
          row.length > most ? row.length : most,
    );
    final bool isMultiplication = domain.id == LearningDomainIds.multiplication;
    return Column(
      spacing: _gap,
      children: <Widget>[
        if (isMultiplication)
          ExcludeSemantics(
            child: Row(
              spacing: _gap,
              children: <Widget>[
                const SizedBox(width: _labelWidth),
                for (int column = 1; column <= columns; column++)
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _rowLabel(context, row.key, isMultiplication),
                      style: labelStyle,
                    ),
                  ),
                ),
              ),
              for (final ItemMasteryEntity cell in row.value)
                Expanded(
                  child: _Cell(cell: cell, domain: domain, onTouch: onTouch),
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
  const _Cell({
    required this.cell,
    required this.domain,
    required this.onTouch,
  });

  static const double _height = 18;
  static const double _radius = 5;

  final ItemMasteryEntity cell;
  final LearningDomain domain;
  final ValueChanged<LearningItem> onTouch;

  @override
  Widget build(BuildContext context) {
    final LearningItem? item = domain.findItem(cell.itemKey);
    final String status = cell.status.nameIn(context.l10n);
    final bool canTouch = item != null && domain.recordingKeyOf(item) != null;
    return Semantics(
      button: canTouch,
      onTap: canTouch ? () => onTouch(item) : null,
      label: item == null
          ? status
          : context.l10n.masteryCellSpoken(
              domain.describeItem(item).toSpokenText(context.l10n),
              status,
            ),
      child: GestureDetector(
        onTap: canTouch ? () => onTouch(item) : null,
        child: Container(
          height: _height,
          decoration: BoxDecoration(
            color: cell.status.colorIn(context.palette),
            borderRadius: BorderRadius.circular(_radius),
          ),
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
                    color: status.colorIn(context.palette),
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
