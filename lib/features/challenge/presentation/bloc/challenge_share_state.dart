import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:meta/meta.dart';

/// Where the code of a game to send to a friend stands.
@immutable
sealed class ChallengeShareState {
  const ChallengeShareState();
}

/// No code asked yet.
final class ChallengeShareIdle extends ChallengeShareState {
  /// Creates the state.
  const ChallengeShareIdle();
}

/// The code is being made.
final class ChallengeSharing extends ChallengeShareState {
  /// Creates the state.
  const ChallengeSharing();
}

/// The code is ready to show.
final class ChallengeShareReady extends ChallengeShareState {
  /// Creates the state.
  const ChallengeShareReady({required this.code});

  /// The ten characters of the code.
  final String code;
}

/// The game could not be coded.
final class ChallengeShareFailed extends ChallengeShareState {
  /// Creates the state.
  const ChallengeShareFailed({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
