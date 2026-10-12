import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_visibility_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_state.dart';

/// "Afficher le classement", the switch of the settings screen that shows
/// or hides the leaderboard for every player of the phone (mockup 13).
///
/// Drawn like the other switches of the settings; it stays disabled until
/// the setting is read.
class LeaderboardVisibilitySwitch extends StatelessWidget {
  /// Creates the switch; the setting comes from the enclosing Cubit.
  const LeaderboardVisibilitySwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final LeaderboardVisibilityCubit cubit = context
        .watch<LeaderboardVisibilityCubit>();
    final bool? isShown = switch (cubit.state) {
      RewardValueLoaded<bool>(:final value) => value,
      _ => null,
    };
    return MergeSemantics(
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          context.l10n.settingsShowLeaderboard,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        value: isShown ?? true,
        onChanged: isShown == null
            ? null
            : (bool value) => cubit.setShown(isShown: value),
      ),
    );
  }
}
