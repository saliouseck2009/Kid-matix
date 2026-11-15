import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_state.dart';

/// Tells the results of a stage whether a next stage can start at once.
///
/// [builder] gets the callback that starts the next stage of the unit, or
/// `null` while the path loads, when the stage just played earned no star
/// (it is still the one to play) and when the unit has no other open
/// stage.
class NextStageScope extends StatelessWidget {
  /// Creates the scope of the results of [played].
  const NextStageScope({
    required this.played,
    required this.onPlay,
    required this.builder,
    super.key,
  });

  /// Stage whose results are shown.
  final StageSource played;

  /// Starts a stage.
  final ValueChanged<StageSource> onPlay;

  /// Builds the buttons from the callback of the next stage, or `null`.
  final Widget Function(VoidCallback? onNext) builder;

  @override
  Widget build(BuildContext context) {
    final StageState? next = switch (context.watch<LearningPathBloc>().state) {
      LearningPathLoaded(:final path) =>
        path.findTable(played.unitKey)?.nextStage,
      _ => null,
    };
    if (next == null || next.kind == played.stage) return builder(null);
    return builder(
      () => onPlay(StageSource(unitKey: played.unitKey, stage: next.kind)),
    );
  }
}
