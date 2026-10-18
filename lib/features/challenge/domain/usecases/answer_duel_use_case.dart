import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_referee.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_rules.dart';
import 'package:kid_matix/features/challenge/domain/usecases/duel_answer_params.dart';

/// Judges an answer of a duel: a right one scores and brings the next
/// question, a wrong one blocks its player. Nothing is saved: the duel
/// never changes the mastery of the facts.
class AnswerDuelUseCase implements UseCase<DuelGameEntity, DuelAnswerParams> {
  /// Creates the use case.
  const AnswerDuelUseCase({required this._domains, required this._random});

  final DomainRegistry _domains;
  final RandomSource _random;

  @override
  Future<DuelGameEntity> call({required DuelAnswerParams params}) async {
    final LearningDomain? domain = _domains.find(DuelRules.domainId);
    if (domain == null) return params.game;
    return DuelReferee(
      domain: domain,
      random: _random,
    ).answer(params.game, params.side, params.answer);
  }
}
