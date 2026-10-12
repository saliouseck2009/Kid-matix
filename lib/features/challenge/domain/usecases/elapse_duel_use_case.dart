import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_referee.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_rules.dart';
import 'package:kid_matix/features/challenge/domain/usecases/duel_elapse_params.dart';

/// Lets time pass in a duel: the blocks after a mistake shorten, and a
/// player whose block ends gets a new question.
class ElapseDuelUseCase implements UseCase<DuelGameEntity, DuelElapseParams> {
  /// Creates the use case.
  const ElapseDuelUseCase({required this._domains, required this._random});

  final DomainRegistry _domains;
  final RandomSource _random;

  @override
  Future<DuelGameEntity> call({required DuelElapseParams params}) async {
    final LearningDomain? domain = _domains.find(DuelRules.domainId);
    if (domain == null) return params.game;
    return DuelReferee(
      domain: domain,
      random: _random,
    ).elapse(params.game, params.elapsed);
  }
}
