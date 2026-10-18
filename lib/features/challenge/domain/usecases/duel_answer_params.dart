import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:meta/meta.dart';

/// An answer given in a duel.
@immutable
final class DuelAnswerParams {
  /// Creates the parameters.
  const DuelAnswerParams({
    required this.game,
    required this.side,
    required this.answer,
  });

  /// The duel as it stands.
  final DuelGameEntity game;

  /// Half of the player who answered.
  final DuelSide side;

  /// Answer tapped.
  final Answer answer;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DuelAnswerParams &&
            other.game == game &&
            other.side == side &&
            other.answer == answer;
  }

  @override
  int get hashCode => Object.hash(game, side, answer);
}
