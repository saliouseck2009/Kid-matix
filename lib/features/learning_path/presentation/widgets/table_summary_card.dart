import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/unit_badge.dart';

/// Top card of the table detail: its badge, its stars out of 15 and the
/// crown to win.
class TableSummaryCard extends StatelessWidget {
  /// Creates the card of [table].
  const TableSummaryCard({
    required this.table,
    required this.labels,
    super.key,
  });

  static const double _badgeSize = 76;

  /// Table shown.
  final TablePathNode table;

  /// Texts of the path.
  final PathLabels labels;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String stars = context.l10n.pathTableStars(
      table.totalStars,
      table.maxStars,
    );
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Row(
        spacing: AppSizes.space16,
        children: <Widget>[
          ExcludeSemantics(
            child: UnitBadge(
              mark: labels.unitMark(table.number),
              style: UnitBadgeStyle.current,
              size: _badgeSize,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: <Widget>[
                Text(stars, style: textTheme.titleMedium),
                ExcludeSemantics(
                  child: AppProgressBar(
                    value: table.totalStars / table.maxStars,
                    semanticLabel: stars,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  context.l10n.pathCrownHint,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.mutedText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
