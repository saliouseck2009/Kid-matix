import 'package:kid_matix/features/challenge/domain/entities/challenge_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_error.dart';
import 'package:meta/meta.dart';

/// What a typed challenge code says: the challenge, or why it is refused.
@immutable
sealed class ChallengeCodeReading {
  const ChallengeCodeReading();
}

/// The code is valid.
final class ChallengeCodeAccepted extends ChallengeCodeReading {
  /// Creates the reading of [code].
  const ChallengeCodeAccepted(this.code);

  /// The challenge the code carries.
  final ChallengeCode code;
}

/// The code is refused.
final class ChallengeCodeRejected extends ChallengeCodeReading {
  /// Creates the refusal for [error].
  const ChallengeCodeRejected(this.error);

  /// Why the code is refused.
  final ChallengeCodeError error;
}
