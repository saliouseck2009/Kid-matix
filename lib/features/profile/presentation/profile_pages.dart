import 'package:flutter/widgets.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/pages/profile_creation_page.dart';
import 'package:kid_matix/features/profile/presentation/pages/who_is_playing_page.dart';

/// Builds the pages of the profile feature for the router.
///
/// Created at the composition root with the use cases resolved there, so
/// no widget ever reads the service locator.
final class ProfilePages {
  /// Creates the factory.
  const ProfilePages({
    required this._getProfiles,
    required this._createProfile,
    required this._selectProfile,
  });

  final GetProfilesUseCase _getProfiles;
  final CreateProfileUseCase _createProfile;
  final SelectProfileUseCase _selectProfile;

  /// "Qui joue ?".
  Widget buildWhoIsPlayingPage() {
    return WhoIsPlayingPage(
      getProfiles: _getProfiles,
      selectProfile: _selectProfile,
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
}
