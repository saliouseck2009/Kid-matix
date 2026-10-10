import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/features/reward/domain/entities/daily_goal_progress.dart';
import 'package:kid_matix/features/reward/domain/entities/session_rewards_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_summary.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_use_cases.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_state.dart';
import 'package:kid_matix/features/reward/presentation/widgets/badge_labels.dart';
import 'package:kid_matix/features/reward/presentation/widgets/daily_goal_card.dart';
import 'package:kid_matix/features/reward/presentation/widgets/reward_celebration.dart';
import 'package:kid_matix/features/reward/presentation/widgets/session_rewards_widgets.dart';
import 'package:kid_matix/features/reward/presentation/widgets/streak_pill.dart';

/// Builds the reward widgets that the router puts into the screens of
/// other features: the results, the map and "Qui joue ?".
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class RewardPages {
  /// Creates the factory.
  const RewardPages({required this._useCases, required this._domains});

  final RewardUseCases _useCases;
  final DomainRegistry _domains;

  /// Provides the rewards of [sessionId] to [child], and plays the
  /// celebrations of a new level and of new badges once they are read.
  Widget buildSessionRewardsScope({
    required String sessionId,
    required Widget child,
  }) {
    return BlocProvider<SessionRewardsCubit>(
      create: (_) => SessionRewardsCubit(
        read: () => _useCases.getSessionRewards(params: sessionId),
      )..load(),
      child:
          BlocListener<
            SessionRewardsCubit,
            RewardValueState<SessionRewardsEntity?>
          >(
            listenWhen: (_, RewardValueState<SessionRewardsEntity?> state) =>
                state is RewardValueLoaded<SessionRewardsEntity?>,
            listener:
                (
                  BuildContext context,
                  RewardValueState<SessionRewardsEntity?> state,
                ) {
                  final SessionRewardsEntity? rewards =
                      (state as RewardValueLoaded<SessionRewardsEntity?>).value;
                  if (rewards == null) return;
                  showRewardCelebrations(
                    context,
                    rewards: rewards,
                    labels: BadgeLabels(domains: _domains, l10n: context.l10n),
                  );
                },
            child: child,
          ),
    );
  }

  /// The XP tile of the results, inside [buildSessionRewardsScope].
  Widget buildSessionXpTile() => const SessionXpTile();

  /// The level and badges of the results, inside
  /// [buildSessionRewardsScope].
  Widget buildSessionLevelCard() {
    return Builder(
      builder: (BuildContext context) => SessionLevelCard(
        labels: BadgeLabels(domains: _domains, l10n: context.l10n),
      ),
    );
  }

  /// The streak pill of [profileId].
  Widget buildStreakPill({required String profileId}) {
    return BlocProvider<RewardValueCubit<StreakSummary>>(
      key: ValueKey<String>('streak-$profileId'),
      create: (_) => RewardValueCubit<StreakSummary>(
        read: () => _useCases.getStreak(params: profileId),
        changes: _useCases.watchChanges(),
      )..load(),
      child: const StreakPill(),
    );
  }

  /// The daily goal card of [profileId].
  Widget buildDailyGoalCard({required String profileId}) {
    return BlocProvider<RewardValueCubit<DailyGoalProgress>>(
      key: ValueKey<String>('goal-$profileId'),
      create: (_) => RewardValueCubit<DailyGoalProgress>(
        read: () => _useCases.getDailyGoal(params: profileId),
        changes: _useCases.watchChanges(),
      )..load(),
      child: const DailyGoalCard(),
    );
  }
}
