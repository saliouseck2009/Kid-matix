import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/frozen_question_generator.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_code_codec.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_rules.dart';
import 'package:kid_matix/features/challenge/domain/services/code_challenge_rules.dart';
import 'package:kid_matix/features/challenge/domain/usecases/challenge_code_params.dart';

/// The challenge code of a game, to send to a friend.
///
/// A free training or a time attack gets a new seed: the friend plays the
/// questions of that seed, with the same tables, mode and timer. A game
/// replayed from a code keeps its seed and version, so a code sent back
/// asks the same questions again with the new score to beat. Fails with a
/// `ValidationException` for another game or one that cannot be coded.
class EncodeChallengeCodeUseCase
    implements UseCase<DataState<String>, ChallengeCodeParams> {
  /// Creates the use case.
  const EncodeChallengeCodeUseCase({
    required this._domains,
    required this._random,
    this._codec = const ChallengeCodeCodec(),
  });

  final DomainRegistry _domains;
  final RandomSource _random;
  final ChallengeCodeCodec _codec;

  /// Returns the ten characters of the code of [params].
  @override
  Future<DataState<String>> call({required ChallengeCodeParams params}) async {
    final ChallengeCode? code = _codeOf(params);
    if (code == null || !_codec.canEncode(code)) {
      return DataFailed<String>(
        ValidationException(message: 'No code for ${params.sourceKey}.'),
      );
    }
    return DataSuccess<String>(_codec.encode(code));
  }

  ChallengeCode? _codeOf(ChallengeCodeParams params) {
    return switch (ChallengeSource.tryParse(params.sourceKey)) {
      TrainingSource(
        :final List<String> unitKeys,
        :final int questionCount,
        :final bool hasTimer,
      ) =>
        _newCode(
          unitKeys: unitKeys,
          mode: hasTimer
              ? ChallengeCodeMode.timedTraining
              : ChallengeCodeMode.training,
          questionCount: questionCount,
          score: params.score,
        ),
      TimeAttackSource(:final List<String> unitKeys) => _newCode(
        unitKeys: unitKeys,
        mode: ChallengeCodeMode.timeAttack,
        questionCount: ChallengeRules.timeAttackQuestionCount,
        score: params.score,
      ),
      CodeChallengeSource(:final ChallengeCode code) => code.copyWith(
        scoreToBeat: params.score,
      ),
      _ => null,
    };
  }

  ChallengeCode? _newCode({
    required List<String> unitKeys,
    required ChallengeCodeMode mode,
    required int questionCount,
    required int score,
  }) {
    final LearningDomain? domain = _domains.find(CodeChallengeRules.domainId);
    final List<LearningUnit?> units = <LearningUnit?>[
      for (final String key in unitKeys) domain?.findUnit(key),
    ];
    if (units.isEmpty || units.contains(null)) return null;
    return ChallengeCode(
      tables: units.map((LearningUnit? unit) => unit!.number),
      mode: mode,
      questionCount: questionCount,
      seed: _random.nextInt(1 << ChallengeCodeCodec.seedBits),
      scoreToBeat: score,
      generatorVersion: FrozenQuestionGenerator.currentVersion,
    );
  }
}
