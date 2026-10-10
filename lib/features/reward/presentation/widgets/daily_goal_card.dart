import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/features/reward/domain/entities/daily_goal_progress.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_state.dart';

/// White card of the map header: "Objectif du jour", the XP earned today
/// out of the goal, and its bar.
class DailyGoalCard extends StatelessWidget {
  /// Creates the card; the progress comes from the enclosing Cubit.
  const DailyGoalCard({super.key});

  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    final DailyGoalProgress? goal = switch (context
        .watch<RewardValueCubit<DailyGoalProgress>>()
        .state) {
      RewardValueLoaded<DailyGoalProgress>(:final value) => value,
      _ => null,
    };
    if (goal == null) return const SizedBox.shrink();
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space8,
        children: <Widget>[
          ExcludeSemantics(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    context.l10n.rewardDailyGoalTitle,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  context.l10n.rewardDailyGoalValue(
                    goal.earnedXp,
                    goal.goalXp,
                  ),
                  style: textTheme.titleMedium?.copyWith(
                    color: context.palette.primaryText,
                  ),
                ),
              ],
            ),
          ),
          AppProgressBar(
            value: goal.progress,
            semanticLabel: context.l10n.rewardDailyGoalSpoken(
              goal.earnedXp,
              goal.goalXp,
            ),
          ),
        ],
      ),
    );
  }
}
