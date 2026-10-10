import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_pill.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_summary.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_state.dart';

/// Pill of the streak of a player: "6 jours" on the warm tint, or "Pas
/// de série".
class StreakPill extends StatelessWidget {
  /// Creates the pill; the streak comes from the enclosing Cubit.
  const StreakPill({super.key});

  @override
  Widget build(BuildContext context) {
    final int days = switch (context
        .watch<RewardValueCubit<StreakSummary>>()
        .state) {
      RewardValueLoaded<StreakSummary>(:final value) => value.current,
      _ => 0,
    };
    return Semantics(
      label: context.l10n.rewardStreakSpoken(days),
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: days == 0
            ? AppPill(label: context.l10n.rewardNoStreak)
            : AppPill(
                label: context.l10n.rewardStreakDays(days),
                icon: Icons.local_fire_department_rounded,
                backgroundColor: context.palette.warmTint,
              ),
      ),
    );
  }
}
