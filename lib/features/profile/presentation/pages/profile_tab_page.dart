import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_use_cases.dart';
import 'package:kid_matix/features/profile/presentation/widgets/delete_profile_dialog.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_view.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_error_message.dart';

/// Profile tab of lot F1: the active player and how to switch, edit or
/// delete them. The full profile screen of lot F10 grows around it.
class ProfileTabPage extends StatelessWidget {
  /// Creates the tab of the player [profileId].
  const ProfileTabPage({
    required this.profileId,
    required this.useCases,
    this.mascotCard,
    super.key,
  });

  /// Identifier of the active player.
  final String profileId;

  /// Use cases of the tab.
  final ProfileTabUseCases useCases;

  /// Card of the mascot under the player, or `null`.
  final Widget? mascotCard;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileTabCubit>(
      create: (_) =>
          ProfileTabCubit(profileId: profileId, useCases: useCases)..load(),
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
            ),
          };
        },
      ),
    );
  }
}

class _ProfileTabView extends StatelessWidget {
  const _ProfileTabView({required this.profile, required this.mascotCard});

  static const double _avatarSize = 92;

  final ProfileEntity profile;
  final Widget? mascotCard;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Widget? mascot = mascotCard;
    final ProfileTabCubit cubit = context.read<ProfileTabCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: ProfileAvatarView(
              avatar: profile.avatar,
              color: profile.color,
              size: _avatarSize,
            ),
          ),
          const SizedBox(height: AppSizes.space12),
          Semantics(
            header: true,
            child: Text(
              profile.nickname,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium,
            ),
          ),
          Text(
            context.l10n.profileLevel(profile.level),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: context.palette.mutedText,
            ),
          ),
          const SizedBox(height: AppSizes.space24),
          if (mascot != null) ...<Widget>[
            mascot,
            const SizedBox(height: AppSizes.space24),
          ],
          DepthButton(
            label: context.l10n.editProfileButton,
            variant: DepthButtonVariant.secondary,
            onPressed: () => context.go(AppRoutes.profileEdit),
          ),
          const SizedBox(height: AppSizes.space12),
          DepthButton(
            label: context.l10n.switchPlayerButton,
            variant: DepthButtonVariant.secondary,
            onPressed: cubit.switchPlayer,
          ),
          const SizedBox(height: AppSizes.space24),
          _DeleteProfileButton(profile: profile),
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
