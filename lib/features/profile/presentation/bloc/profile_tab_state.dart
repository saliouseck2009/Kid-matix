import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';

/// What the Profile tab shows.
sealed class ProfileTabState {
  /// Creates a state.
  const ProfileTabState();
}

/// The active player is loading, or the tab is being left.
final class ProfileTabLoading extends ProfileTabState {
  /// Creates the state.
  const ProfileTabLoading();
}

/// The active player is shown.
final class ProfileTabLoaded extends ProfileTabState {
  /// Creates the state.
  const ProfileTabLoaded({required this.profile});

  /// The active player.
  final ProfileEntity profile;
}

/// The player could not be loaded, switched or deleted.
final class ProfileTabFailure extends ProfileTabState {
  /// Creates the state.
  const ProfileTabFailure({required this.errorCode});

  /// Reason of the failure, turned into text by the screen.
  final AppErrorCode errorCode;
}
