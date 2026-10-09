import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';

/// What the "Qui joue ?" screen shows.
sealed class ProfilesState {
  /// Creates a state.
  const ProfilesState();
}

/// The profiles are loading, or the chosen player is being opened.
final class ProfilesLoading extends ProfilesState {
  /// Creates the state.
  const ProfilesLoading();
}

/// The profiles are ready to be shown.
final class ProfilesLoaded extends ProfilesState {
  /// Creates the state.
  const ProfilesLoaded({required this.profiles, required this.canAddProfile});

  /// Every profile, oldest first.
  final List<ProfileEntity> profiles;

  /// Whether the device can hold one more profile.
  final bool canAddProfile;
}

/// The profiles could not be loaded or the player could not be opened.
final class ProfilesFailure extends ProfilesState {
  /// Creates the state.
  const ProfilesFailure({required this.errorCode});

  /// Reason of the failure, turned into text by the screen.
  final AppErrorCode errorCode;
}
