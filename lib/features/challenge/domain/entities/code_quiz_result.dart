import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_error.dart';
import 'package:meta/meta.dart';

/// The quiz of a typed challenge code, or why the code is refused.
@immutable
sealed class CodeQuizResult {
  const CodeQuizResult();
}

/// The code is valid: its quiz is ready to play.
final class CodeQuizReady extends CodeQuizResult {
  /// Creates the result.
  const CodeQuizReady({required this.code, required this.spec});

  /// The challenge the code carries.
  final ChallengeCode code;

  /// The quiz to play: the questions of the code's seed.
  final QuizSpec spec;
}

/// The code is refused.
final class CodeQuizRejected extends CodeQuizResult {
  /// Creates the refusal for [error].
  const CodeQuizRejected(this.error);

  /// Why the code is refused.
  final ChallengeCodeError error;
}
