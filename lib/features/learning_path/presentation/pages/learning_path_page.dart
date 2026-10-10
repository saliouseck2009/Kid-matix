import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_header.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_map.dart';

/// The home of the app: the map of the 12 tables.
///
/// Its header shows the player, the streak, the crowns and the daily
/// goal.
class LearningPathPage extends StatelessWidget {
  /// Creates the map of the path of [params].
  const LearningPathPage({
    required this.params,
    required this.useCases,
    required this.onOpenTable,
    required this.onPlay,
    this.header,
    super.key,
  });

  /// Player and domain of the path.
  final LearningPathParams params;

  /// Use cases of the path.
  final LearningPathUseCases useCases;

  /// Opens the detail of a table.
  final ValueChanged<String> onOpenTable;

  /// Starts a stage.
  final ValueChanged<StageSource> onPlay;

  /// Player, streak and daily goal at the top of the map, or `null`.
  final PathHeaderSlots? header;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LearningPathBloc>(
      create: (_) =>
          LearningPathBloc(params: params, useCases: useCases)
            ..add(const LearningPathStarted()),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<LearningPathBloc, LearningPathState>(
            builder: (BuildContext context, LearningPathState state) {
              final PathLabels labels = PathLabels(
                domainId: params.domainId,
                l10n: context.l10n,
              );
              return switch (state) {
                LearningPathLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                LearningPathFailure(:final errorCode) => Center(
                  child: Text(labels.describeError(errorCode)),
                ),
                LearningPathLoaded(:final path) => PathMap(
                  path: path,
                  labels: labels,
                  onOpenTable: onOpenTable,
                  onPlay: onPlay,
                  header: header,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}
