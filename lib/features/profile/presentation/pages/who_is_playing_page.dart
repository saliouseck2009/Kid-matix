import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profiles_bloc.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profiles_event.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profiles_state.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_error_message.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_grid.dart';

/// "Qui joue ?": the players of the phone, shown while nobody is playing.
class WhoIsPlayingPage extends StatelessWidget {
  /// Creates the page with the use cases its Bloc needs.
  const WhoIsPlayingPage({
    required this.getProfiles,
    required this.selectProfile,
    super.key,
  });

  /// Lists the players.
  final GetProfilesUseCase getProfiles;

  /// Opens a player's session.
  final SelectProfileUseCase selectProfile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfilesBloc>(
      create: (_) =>
          ProfilesBloc(getProfiles: getProfiles, selectProfile: selectProfile)
            ..add(const ProfilesRequested()),
      child: const _WhoIsPlayingView(),
    );
  }
}

class _WhoIsPlayingView extends StatelessWidget {
  const _WhoIsPlayingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfilesBloc, ProfilesState>(
          builder: (BuildContext context, ProfilesState state) {
            return switch (state) {
              ProfilesLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              ProfilesFailure() => _ProfilesFailureView(state: state),
              ProfilesLoaded() => ProfileGrid(
                profiles: state.profiles,
                canAddProfile: state.canAddProfile,
                onProfileTap: (ProfileEntity profile) => context
                    .read<ProfilesBloc>()
                    .add(ProfileSelected(profileId: profile.id)),
                onNewPlayerTap: () => context.go(AppRoutes.profileCreation),
              ),
            };
          },
        ),
      ),
    );
  }
}

class _ProfilesFailureView extends StatelessWidget {
  const _ProfilesFailureView({required this.state});

  final ProfilesFailure state;

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
              onPressed: () =>
                  context.read<ProfilesBloc>().add(const ProfilesRequested()),
            ),
          ],
        ),
      ),
    );
  }
}
