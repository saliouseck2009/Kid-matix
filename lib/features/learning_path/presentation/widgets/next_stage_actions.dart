import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_state.dart';

/// What the results of a stage offer to go on: "Étape suivante", which
/// starts the next stage of the unit at once, above "Retour au parcours".
///
/// Shows [fallback] alone while the path loads, when the stage just played
/// earned no star (it is still the one to play) and when the unit has no
/// other open stage.
class NextStageActions extends StatelessWidget {
  /// Creates the actions shown after [played].
  const NextStageActions({
    required this.played,
    required this.fallback,
    required this.onBack,
    required this.onPlay,
    super.key,
  });

  /// Stage whose results are shown.
  final StageSource played;

  /// Button shown when there is no next stage to start.
  final Widget fallback;

  /// Goes back where the stage was started.
  final VoidCallback onBack;

  /// Starts a stage.
  final ValueChanged<StageSource> onPlay;

  @override
  Widget build(BuildContext context) {
    final StageState? next = switch (context.watch<LearningPathBloc>().state) {
      LearningPathLoaded(:final path) =>
        path.findTable(played.unitKey)?.nextStage,
      _ => null,
    };
    if (next == null || next.kind == played.stage) return fallback;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space16,
      children: <Widget>[
        DepthButton(
          label: context.l10n.pathNextStage,
          onPressed: () => onPlay(
            StageSource(unitKey: played.unitKey, stage: next.kind),
          ),
        ),
        DepthButton(
          label: context.l10n.pathBackToPath,
          variant: DepthButtonVariant.secondary,
          onPressed: onBack,
        ),
      ],
    );
  }
}
