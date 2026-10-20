import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_choice_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_cubit.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/domain_switch.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_header.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_map.dart';

/// The home of the app: the map of the units of the domain the player
/// chose, the switch of the domains on top when the app has two or more.
///
/// Its header shows the player, the streak, the crowns and the daily
/// goal.
class LearningPathPage extends StatelessWidget {
  /// Creates the map of the path of [profileId].
  const LearningPathPage({
    required this.profileId,
    required this.useCases,
    required this.domainChoice,
    required this.onOpenTable,
    required this.onPlay,
    this.header,
    this.mascot,
    this.banner,
    super.key,
  });

  /// Player of the path.
  final String profileId;

  /// Use cases of the path.
  final LearningPathUseCases useCases;

  /// Use cases of the domain switch.
  final DomainChoiceUseCases domainChoice;

  /// Opens the detail of a table.
  final ValueChanged<String> onOpenTable;

  /// Starts a stage.
  final ValueChanged<StageSource> onPlay;

  /// Player, streak and daily goal at the top of the map, or `null`.
  final PathHeaderSlots? header;

  /// The mascot under the current table, or `null`.
  final Widget? mascot;

  /// Above the map, such as « Le devoir de la classe » of a pupil, or
  /// `null`.
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DomainChoiceCubit>(
      create: (_) =>
          DomainChoiceCubit(profileId: profileId, useCases: domainChoice)
            ..load(),
      child: Scaffold(
        body: SafeArea(
          child: _WithBanner(
            banner: banner,
            child: BlocBuilder<DomainChoiceCubit, DomainChoiceState>(
              builder: (BuildContext context, DomainChoiceState state) {
                final DomainChoiceEntity choice;
                switch (state) {
                  case DomainChoiceLoading():
                    return const Center(child: CircularProgressIndicator());
                  case DomainChoiceFailure(:final errorCode):
                    return Center(
                      child: Text(
                        PathLabels(
                          domainId: LearningDomainIds.multiplication,
                          l10n: context.l10n,
                        ).describeError(errorCode),
                      ),
                    );
                  case DomainChoiceLoaded():
                    choice = state.choice;
                }
                return _DomainPath(
                  key: ValueKey<String>(choice.selectedId),
                  params: LearningPathParams(
                    profileId: profileId,
                    domainId: choice.selectedId,
                  ),
                  useCases: useCases,
                  domainSwitch: choice.hasChoice
                      ? DomainSwitch(choice: choice)
                      : null,
                  onOpenTable: onOpenTable,
                  onPlay: onPlay,
                  header: header,
                  mascot: mascot,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// [child] under [banner], when there is one.
class _WithBanner extends StatelessWidget {
  const _WithBanner({required this.banner, required this.child});

  final Widget? banner;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Widget? above = banner;
    if (above == null) return child;
    return Column(
      children: <Widget>[
        above,
        Expanded(child: child),
      ],
    );
  }
}

/// The map of one domain, read again after each session or settings
/// change.
class _DomainPath extends StatelessWidget {
  const _DomainPath({
    required this.params,
    required this.useCases,
    required this.domainSwitch,
    required this.onOpenTable,
    required this.onPlay,
    required this.header,
    required this.mascot,
    super.key,
  });

  final LearningPathParams params;
  final LearningPathUseCases useCases;
  final Widget? domainSwitch;
  final ValueChanged<String> onOpenTable;
  final ValueChanged<StageSource> onPlay;
  final PathHeaderSlots? header;
  final Widget? mascot;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LearningPathBloc>(
      create: (_) =>
          LearningPathBloc(params: params, useCases: useCases)
            ..add(const LearningPathStarted()),
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
              domainSwitch: domainSwitch,
              mascot: mascot,
            ),
          };
        },
      ),
    );
  }
}
