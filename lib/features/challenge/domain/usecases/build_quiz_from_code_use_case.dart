import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_error.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_reading.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/code_quiz_result.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_code_codec.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_quiz_specs.dart';
import 'package:kid_matix/features/challenge/domain/services/code_challenge_rules.dart';

/// The quiz of a challenge code typed by the child: the questions of its
/// seed, drawn by the frozen generator of its version, with the timer
/// rules of its mode.
///
/// The code is refused when it is no code, when a character was changed
/// or swapped (check character), or when it comes from a newer generator.
class BuildQuizFromCodeUseCase implements UseCase<CodeQuizResult, String> {
  /// Creates the use case.
  const BuildQuizFromCodeUseCase({
    required this._domains,
    this._codec = const ChallengeCodeCodec(),
    this._specs = const ChallengeQuizSpecs(),
  });

  final DomainRegistry _domains;
  final ChallengeCodeCodec _codec;
  final ChallengeQuizSpecs _specs;

  /// Reads the code [params], as typed, spaces and dashes allowed.
  @override
  Future<CodeQuizResult> call({required String params}) async {
    return switch (_codec.decode(params)) {
      ChallengeCodeRejected(:final ChallengeCodeError error) =>
        CodeQuizRejected(error),
      ChallengeCodeAccepted(:final ChallengeCode code) => _quizOf(code),
    };
  }

  CodeQuizResult _quizOf(ChallengeCode code) {
    final LearningDomain? domain = _domains.find(CodeChallengeRules.domainId);
    final QuizSpec? spec = domain == null
        ? null
        : _specs.specOf(
            domain: domain,
            source: CodeChallengeSource(code: code),
          );
    return spec == null
        ? const CodeQuizRejected(ChallengeCodeError.malformed)
        : CodeQuizReady(code: code, spec: spec);
  }
}
