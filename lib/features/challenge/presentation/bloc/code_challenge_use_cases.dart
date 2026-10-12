import 'package:kid_matix/features/challenge/domain/usecases/build_quiz_from_code_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/encode_challenge_code_use_case.dart';

/// The use cases the Cubits of the challenge by code call.
final class CodeChallengeUseCases {
  /// Groups the use cases.
  const CodeChallengeUseCases({
    required this.encode,
    required this.buildQuizFromCode,
  });

  /// The code of a game, to send to a friend.
  final EncodeChallengeCodeUseCase encode;

  /// The quiz of a code typed by the child.
  final BuildQuizFromCodeUseCase buildQuizFromCode;
}
