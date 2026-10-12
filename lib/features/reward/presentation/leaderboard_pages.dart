import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_use_cases.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_visibility_cubit.dart';
import 'package:kid_matix/features/reward/presentation/pages/leaderboard_page.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_avatar_builder.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_entry_card.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_visibility_switch.dart';

/// Builds the weekly leaderboard, its card on the Profile tab and its
/// switch in the settings, for the router.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class LeaderboardPages {
  /// Creates the factory.
  const LeaderboardPages({required this._useCases});

  final LeaderboardUseCases _useCases;

  /// The leaderboard seen by [profileId]; [avatarOf] draws the players
  /// and [onBack] goes back.
  Widget buildLeaderboardPage({
    required String profileId,
    required LeaderboardAvatarBuilder avatarOf,
    required VoidCallback onBack,
  }) {
    return BlocProvider<LeaderboardCubit>(
      create: (_) => LeaderboardCubit(
        profileId: profileId,
        getLeaderboard: _useCases.getLeaderboard,
        changes: _useCases.watchRewardChanges(),
      )..load(),
      child: LeaderboardPage(avatarOf: avatarOf, onBack: onBack),
    );
  }

  /// The card that opens the leaderboard with [onOpen], hidden with it.
  Widget buildEntryCard({required VoidCallback onOpen}) {
    return BlocProvider<LeaderboardVisibilityCubit>(
      create: (_) => _createVisibilityCubit()..load(),
      child: LeaderboardEntryCard(onOpen: onOpen),
    );
  }

  /// "Afficher le classement" for the settings screen.
  Widget buildVisibilitySwitch() {
    return BlocProvider<LeaderboardVisibilityCubit>(
      create: (_) => _createVisibilityCubit()..load(),
      child: const LeaderboardVisibilitySwitch(),
    );
  }

  LeaderboardVisibilityCubit _createVisibilityCubit() {
    return LeaderboardVisibilityCubit(
      get: _useCases.getVisibility,
      set: _useCases.setVisibility,
      watch: _useCases.watchVisibility,
    );
  }
}
