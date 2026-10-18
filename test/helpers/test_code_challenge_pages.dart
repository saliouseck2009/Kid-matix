import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/services/seeded_random_source.dart';
import 'package:kid_matix/features/challenge/domain/usecases/build_quiz_from_code_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/encode_challenge_code_use_case.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_challenge_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/code_challenge_pages.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

/// Use cases of the challenge by code over the multiplication domain;
/// the seeds come from [randomSeed].
CodeChallengeUseCases buildTestCodeChallengeUseCases({int randomSeed = 3}) {
  final DomainRegistry domains = DomainRegistry()
    ..register(MultiplicationDomain());
  return CodeChallengeUseCases(
    encode: EncodeChallengeCodeUseCase(
      domains: domains,
      random: SeededRandomSource(seed: randomSeed),
    ),
    buildQuizFromCode: BuildQuizFromCodeUseCase(domains: domains),
  );
}

/// The challenge by code over the multiplication domain.
CodeChallengePages buildTestCodeChallengePages({
  CodeChallengeUseCases? useCases,
}) {
  return CodeChallengePages(
    useCases: useCases ?? buildTestCodeChallengeUseCases(),
    domains: DomainRegistry()..register(MultiplicationDomain()),
  );
}
