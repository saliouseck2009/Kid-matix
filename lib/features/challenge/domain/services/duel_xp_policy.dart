import 'package:kid_matix/features/challenge/domain/entities/duel_contender.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_outcome.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_rules.dart';

/// XP of a duel (owner's choice): 10 per right answer and 20 more for the
/// winner; the loser keeps theirs and a guest earns nothing.
final class DuelXpPolicy {
  /// Creates the policy.
  const DuelXpPolicy();

  /// XP earned by [contender], the winner when [isWinner].
  int xpOf({required DuelContender contender, required bool isWinner}) {
    if (contender.player is GuestDuelPlayer) return 0;
    final int bonus = isWinner ? DuelRules.winnerBonusXp : 0;
    return contender.score * DuelRules.xpPerRightAnswer + bonus;
  }

  /// The outcome of [game] won by [winner].
  DuelOutcome outcomeOf(DuelGameEntity game, {required DuelSide winner}) {
    return DuelOutcome(
      winner: winner,
      topXp: xpOf(contender: game.top, isWinner: winner == DuelSide.top),
      bottomXp: xpOf(
        contender: game.bottom,
        isWinner: winner == DuelSide.bottom,
      ),
    );
  }
}
