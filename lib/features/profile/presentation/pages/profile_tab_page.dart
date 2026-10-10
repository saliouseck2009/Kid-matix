import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_stats_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/progress_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_use_cases.dart';
import 'package:kid_matix/features/profile/presentation/widgets/delete_profile_dialog.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_error_message.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_header.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_stat_tile.dart';

/// The Profile tab (mockup 12): the player, their streak, crowns and
/// badges, the mascot card and the sections of the other features.
class ProfileTabPage extends StatelessWidget {
  /// Creates the tab of the player [profileId].
  const ProfileTabPage({
    required this.profileId,
    required this.useCases,
    this.mascotCard,
    this.sections = const <Widget>[],
    super.key,
  });

  /// Identifier of the active player.
  final String profileId;

  /// Use cases of the tab.
  final ProfileTabUseCases useCases;

  /// Card of the mascot under the figures, or `null`.
  final Widget? mascotCard;

  /// Cards of the other features under the mascot, such as the mastery
  /// grid.
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<Object?>>[
        BlocProvider<ProfileTabCubit>(
          create: (_) =>
              ProfileTabCubit(profileId: profileId, useCases: useCases)..load(),
        ),
        BlocProvider<ProgressCubit>(
          create: (_) => ProgressCubit(
            profileId: profileId,
            getStats: useCases.getStats,
            watchChanges: useCases.watchProgress,
          )..load(),
        ),
      ],
      child: BlocBuilder<ProfileTabCubit, ProfileTabState>(
        builder: (BuildContext context, ProfileTabState state) {
          return switch (state) {
            ProfileTabLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ProfileTabFailure() => _ProfileTabFailureView(state: state),
            ProfileTabLoaded() => _ProfileTabView(
              profile: state.profile,
              mascotCard: mascotCard,
              sections: sections,
            ),
          };
        },
      ),
    );
  }
}

class _ProfileTabView extends StatelessWidget {
  const _ProfileTabView({
    required this.profile,
    required this.mascotCard,
    required this.sections,
  });

  static const double _gap = 14;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSizes.space24,
    20,
    AppSizes.space24,
    AppSizes.space24,
  );

  final ProfileEntity profile;
  final Widget? mascotCard;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    final Widget? mascot = mascotCard;
    final ProfileTabCubit cubit = context.read<ProfileTabCubit>();
    return ListView(
      padding: _padding,
      children: <Widget>[
        ProfileHeader(
          profile: profile,
          onEdit: () => context.go(AppRoutes.profileEdit),
          actions: <Widget>[
            AppIconButton(
              icon: Icons.swap_vert_rounded,
              tooltip: context.l10n.switchPlayerButton,
              onPressed: cubit.switchPlayer,
            ),
          ],
        ),
        const SizedBox(height: _gap),
        const _ProgressTiles(),
        if (mascot != null) ...<Widget>[const SizedBox(height: _gap), mascot],
        for (final Widget section in sections) ...<Widget>[
          const SizedBox(height: _gap),
          section,
        ],
        const SizedBox(height: AppSizes.space24),
        _DeleteProfileButton(profile: profile),
      ],
    );
  }
}

/// Streak, crowns and badges, side by side; dashes until they are read.
class _ProgressTiles extends StatelessWidget {
  const _ProgressTiles();

  static const double _gap = 10;
  static const String _unknown = '–';

  @override
  Widget build(BuildContext context) {
    final ProfileStatsEntity? stats = context.watch<ProgressCubit>().state;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _gap,
        children: <Widget>[
          Expanded(
            child: ProfileStatTile(
              value: stats == null
                  ? _unknown
                  : context.l10n.profileStreakDays(stats.streak),
              label: context.l10n.profileStreakLabel,
              isHighlighted: true,
            ),
          ),
          Expanded(
            child: ProfileStatTile(
              value: stats == null ? _unknown : '${stats.crownCount}',
              label: context.l10n.profileCrownsLabel(stats?.crownCount ?? 0),
            ),
          ),
          Expanded(
            child: ProfileStatTile(
              value: stats == null ? _unknown : '${stats.badgeCount}',
              label: context.l10n.profileBadgesLabel(stats?.badgeCount ?? 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteProfileButton extends StatelessWidget {
  const _DeleteProfileButton({required this.profile});

  final ProfileEntity profile;

  Future<void> _confirmAndDelete(BuildContext context) async {
    final ProfileTabCubit cubit = context.read<ProfileTabCubit>();
    final bool isConfirmed = await confirmProfileDeletion(
      context,
      nickname: profile.nickname,
    );
    if (isConfirmed) await cubit.deleteProfile();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _confirmAndDelete(context),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
        minimumSize: const Size.fromHeight(AppSizes.minTouchTarget),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: Text(context.l10n.deleteProfileButton),
    );
  }
}

class _ProfileTabFailureView extends StatelessWidget {
  const _ProfileTabFailureView({required this.state});

  final ProfileTabFailure state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              liveRegion: true,
              child: Text(
                state.errorCode.toProfileMessage(context.l10n),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            DepthButton(
              label: context.l10n.commonRetry,
              onPressed: context.read<ProfileTabCubit>().load,
            ),
          ],
        ),
      ),
    );
  }
}
