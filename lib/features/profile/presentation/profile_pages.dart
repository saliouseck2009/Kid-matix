import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_use_cases.dart';
import 'package:kid_matix/features/profile/presentation/pages/profile_creation_page.dart';
import 'package:kid_matix/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:kid_matix/features/profile/presentation/pages/profile_tab_page.dart';
import 'package:kid_matix/features/profile/presentation/pages/who_is_playing_page.dart';
import 'package:kid_matix/features/profile/presentation/widgets/player_badge.dart';

/// Builds the pages of the profile feature for the router.
///
/// Created at the composition root with the use cases resolved there, so
/// no widget ever reads the service locator.
final class ProfilePages {
  /// Creates the factory.
  const ProfilePages({
    required this._getProfiles,
    required this._getProfile,
    required this._createProfile,
    required this._updateProfile,
    required this._selectProfile,
    required this._tabUseCases,
  });

  final GetProfilesUseCase _getProfiles;
  final GetProfileUseCase _getProfile;
  final CreateProfileUseCase _createProfile;
  final UpdateProfileUseCase _updateProfile;
  final SelectProfileUseCase _selectProfile;
  final ProfileTabUseCases _tabUseCases;

  /// "Qui joue ?".
  Widget buildWhoIsPlayingPage({
    Widget Function(String profileId)? footerOf,
  }) {
    return WhoIsPlayingPage(
      getProfiles: _getProfiles,
      selectProfile: _selectProfile,
      footerOf: footerOf,
    );
  }

  /// The player [profileId] at the top of the map: avatar, nickname and
  /// level, refreshed after each quiz.
  Widget buildPlayerBadge({required String profileId}) {
    return BlocProvider<ProfileTabCubit>(
      key: ValueKey<String>('badge-$profileId'),
      create: (_) =>
          ProfileTabCubit(profileId: profileId, useCases: _tabUseCases)..load(),
      child: const PlayerBadge(),
    );
  }

  /// Creation of a player; [canGoBack] when other players exist.
  Widget buildProfileCreationPage({required bool canGoBack}) {
    return ProfileCreationPage(
      createProfile: _createProfile,
      selectProfile: _selectProfile,
      canGoBack: canGoBack,
    );
  }

  /// Profile tab of the player [profileId].
  Widget buildProfileTabPage({
    required String profileId,
    Widget? mascotCard,
  }) {
    return ProfileTabPage(
      profileId: profileId,
      useCases: _tabUseCases,
      mascotCard: mascotCard,
    );
  }

  /// Edition of the player [profileId].
  Widget buildProfileEditPage({required String profileId}) {
    return ProfileEditPage(
      profileId: profileId,
      getProfile: _getProfile,
      updateProfile: _updateProfile,
    );
  }
}
