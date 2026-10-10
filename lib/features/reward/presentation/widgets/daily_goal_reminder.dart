import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/speech_bubble.dart';
import 'package:kid_matix/features/reward/domain/entities/daily_goal_progress.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_state.dart';

/// What the mascot says about the daily goal: the XP still missing, or
/// its congratulations once the goal is reached.
class DailyGoalReminder extends StatelessWidget {
  /// Creates the reminder; the progress comes from the enclosing Cubit.
  const DailyGoalReminder({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyGoalProgress? goal = switch (context
        .watch<RewardValueCubit<DailyGoalProgress>>()
        .state) {
      RewardValueLoaded<DailyGoalProgress>(:final value) => value,
      _ => null,
    };
    if (goal == null) return const SizedBox.shrink();
    return SpeechBubble(
      text: goal.isReached
          ? context.l10n.mascotGoalReached
          : context.l10n.mascotGoalReminder(goal.goalXp - goal.earnedXp),
    );
  }
}
