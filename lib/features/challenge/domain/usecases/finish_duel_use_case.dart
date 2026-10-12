import 'dart:developer';

import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/xp_award_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_outcome.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_rules.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_xp_policy.dart';

/// Ends a won duel: gives each player of the phone their XP and returns
/// the outcome. Only XP are written: no streak, badge or mastery.
class FinishDuelUseCase implements UseCase<DuelOutcome, DuelGameEntity> {
  /// Creates the use case.
  const FinishDuelUseCase({
    required this._xpAwards,
    this._policy = const DuelXpPolicy(),
  });

  static const String _logName = 'duel';

  final XpAwardService _xpAwards;
  final DuelXpPolicy _policy;

  /// Throws an [ArgumentError] when nobody has won [params] yet.
  @override
  Future<DuelOutcome> call({required DuelGameEntity params}) async {
    final DuelSide? winner = params.winner;
    if (winner == null) throw ArgumentError.value(params, 'params', 'Not won');
    final DuelOutcome outcome = _policy.outcomeOf(params, winner: winner);
    bool isSaved = true;
    for (final DuelSide side in DuelSide.values) {
      final String? profileId = params.of(side).player.profileId;
      final int xp = outcome.xpOf(side);
      if (profileId == null || xp <= 0) continue;
      final DataState<void> saved = await _xpAwards.awardXp(
        profileId: profileId,
        xp: xp,
        sourceKey: DuelRules.xpSourceKey,
      );
      if (saved case DataFailed<void>(:final exception)) {
        log('Duel XP not saved', name: _logName, error: exception);
        isSaved = false;
      }
    }
    return outcome.copyWith(isXpSaved: isSaved);
  }
}
