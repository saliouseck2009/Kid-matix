import 'package:kid_matix/features/challenge/domain/entities/challenge_code_error.dart';
import 'package:meta/meta.dart';

/// Where the code typed by the child stands.
@immutable
sealed class CodeEntryState {
  const CodeEntryState();
}

/// The child is typing.
final class CodeEntryIdle extends CodeEntryState {
  /// Creates the state.
  const CodeEntryIdle();
}

/// The code is being read.
final class CodeEntryChecking extends CodeEntryState {
  /// Creates the state.
  const CodeEntryChecking();
}

/// The code is refused.
final class CodeEntryRejected extends CodeEntryState {
  /// Creates the state.
  const CodeEntryRejected({required this.error});

  /// Why the code is refused.
  final ChallengeCodeError error;
}

/// The code is valid: its game can start.
final class CodeEntryAccepted extends CodeEntryState {
  /// Creates the state.
  const CodeEntryAccepted({required this.sourceKey});

  /// Source key of the game of the code.
  final String sourceKey;
}
