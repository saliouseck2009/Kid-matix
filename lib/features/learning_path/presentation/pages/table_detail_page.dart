import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/stage_card.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/table_summary_card.dart';

/// The detail of a table: its stars, its five stages and "Voir la table".
///
/// The next stage is highlighted with "Jouer", so after the results
/// "Continuer" lands here with the following stage ready.
class TableDetailPage extends StatelessWidget {
  /// Creates the detail of the table [unitKey].
  const TableDetailPage({
    required this.params,
    required this.unitKey,
    required this.useCases,
    required this.onBack,
    required this.onPlay,
    required this.onShowTable,
    super.key,
  });

  /// Player and domain of the path.
  final LearningPathParams params;

  /// Key of the table, such as `mul:5`.
  final String unitKey;

  /// Use cases of the path.
  final LearningPathUseCases useCases;

  /// Goes back to the map.
  final VoidCallback onBack;

  /// Starts a stage.
  final ValueChanged<StageSource> onPlay;

  /// Shows the whole table and its tip.
  final VoidCallback onShowTable;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LearningPathBloc>(
      create: (_) =>
          LearningPathBloc(params: params, useCases: useCases)
            ..add(const LearningPathStarted()),
      child: BackToParent(
        onBack: onBack,
        child: Scaffold(
          body: SafeArea(
            child: BlocBuilder<LearningPathBloc, LearningPathState>(
              builder: (BuildContext context, LearningPathState state) {
                final PathLabels labels = PathLabels(
                  domainId: params.domainId,
                  l10n: context.l10n,
                );
                final TablePathNode? table = switch (state) {
                  LearningPathLoaded(:final path) => path.findTable(unitKey),
                  _ => null,
                };
                return switch (state) {
                  LearningPathLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  LearningPathFailure(:final errorCode) => Center(
                    child: Text(labels.describeError(errorCode)),
                  ),
                  LearningPathLoaded() when table == null => Center(
                    child: Text(context.l10n.errorUnknown),
                  ),
                  LearningPathLoaded() => _TableDetailView(
                    table: table!,
                    labels: labels,
                    onBack: onBack,
                    onPlay: onPlay,
                    onShowTable: onShowTable,
                  ),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TableDetailView extends StatelessWidget {
  const _TableDetailView({
    required this.table,
    required this.labels,
    required this.onBack,
    required this.onPlay,
    required this.onShowTable,
  });

  final TablePathNode table;
  final PathLabels labels;
  final VoidCallback onBack;
  final ValueChanged<StageSource> onPlay;
  final VoidCallback onShowTable;

  @override
  Widget build(BuildContext context) {
    final StageState? next = table.nextStage;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space24,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: <Widget>[
          Row(
            spacing: AppSizes.space12,
            children: <Widget>[
              AppIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: context.l10n.pathTableBack,
                onPressed: onBack,
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    labels.unitName(table.number),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: <Widget>[
                  TableSummaryCard(table: table, labels: labels),
                  const SizedBox(height: AppSizes.space4),
                  for (final StageState stage in table.stages)
                    StageCard(
                      stage: stage,
                      isNext: identical(stage, next),
                      labels: labels,
                      onPlay: () => onPlay(
                        StageSource(unitKey: table.unitKey, stage: stage.kind),
                      ),
                    ),
                ],
              ),
            ),
          ),
          DepthButton(
            label: context.l10n.pathShowTable,
            variant: DepthButtonVariant.secondary,
            onPressed: onShowTable,
          ),
        ],
      ),
    );
  }
}
