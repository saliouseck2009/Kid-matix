import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_definition.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';

/// Call card next to the current table: its name, the next stage and
/// "Jouer".
class CurrentTableCard extends StatelessWidget {
  /// Creates the card of [table].
  const CurrentTableCard({
    required this.table,
    required this.labels,
    required this.onPlay,
    super.key,
  });

  /// The current table.
  final TablePathNode table;

  /// Texts of the path.
  final PathLabels labels;

  /// Starts the next stage, or opens the table when none is left.
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final StageState? next = table.nextStage;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.space16,
        14,
        AppSizes.space16,
        AppSizes.space16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space4,
        children: <Widget>[
          Text(labels.unitName(table.number), style: textTheme.titleLarge),
          if (next != null)
            Text(
              context.l10n.pathCurrentStage(
                next.definition.number,
                StageDefinition.tableStages.length,
                labels.stageName(next.kind),
              ),
              style: textTheme.bodyMedium?.copyWith(
                color: context.palette.mutedText,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: AppSizes.space4),
          DepthButton(label: context.l10n.pathPlay, onPressed: onPlay),
        ],
      ),
    );
  }
}
