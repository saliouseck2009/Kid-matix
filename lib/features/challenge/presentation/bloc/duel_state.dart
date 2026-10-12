import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_lineup.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_outcome.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:meta/meta.dart';

/// What the duel screen shows.
@immutable
sealed class DuelState {
  const DuelState();
}

/// The players or the first questions are being read.
final class DuelLoading extends DuelState {
  /// Creates the state.
  const DuelLoading();
}

/// The players or the questions could not be read.
final class DuelFailure extends DuelState {
  /// Creates the state.
  const DuelFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}

/// The two players are being chosen.
final class DuelChoosingPlayers extends DuelState {
  /// Creates the state.
  const DuelChoosingPlayers({required this.players, this.top, this.bottom});

  /// Players of the phone, oldest first.
  final List<PlayerIdentity> players;

  /// Player picked for the top half, or `null`.
  final DuelPlayer? top;

  /// Player picked for the bottom half, or `null`.
  final DuelPlayer? bottom;

  /// The player picked for [side], or `null`.
  DuelPlayer? playerOf(DuelSide side) => side == DuelSide.top ? top : bottom;

  /// The lineup once both players can play together, else `null`.
  DuelLineup? get lineup {
    final DuelPlayer? top = this.top;
    final DuelPlayer? bottom = this.bottom;
    if (top == null || bottom == null) return null;
    if (!DuelLineup.isValid(top: top, bottom: bottom)) return null;
    return DuelLineup(top: top, bottom: bottom);
  }

  /// Returns a copy where [player] holds [side].
  DuelChoosingPlayers withPlayer(DuelSide side, DuelPlayer player) {
    return DuelChoosingPlayers(
      players: players,
      top: side == DuelSide.top ? player : top,
      bottom: side == DuelSide.bottom ? player : bottom,
    );
  }
}

/// The race is on.
final class DuelRunning extends DuelState {
  /// Creates the state.
  const DuelRunning({
    required this.lineup,
    required this.game,
    this.answerCount = 0,
    this.isLastAnswerRight,
  });

  /// Who plays which half.
  final DuelLineup lineup;

  /// Questions, scores and blocks of both players.
  final DuelGameEntity game;

  /// Answers judged so far, by both players.
  final int answerCount;

  /// Whether the last answer judged was right; `null` before the first.
  final bool? isLastAnswerRight;
}

/// A player won: the XP are being saved.
final class DuelSaving extends DuelState {
  /// Creates the state.
  const DuelSaving({required this.lineup, required this.game});

  /// Who played which half.
  final DuelLineup lineup;

  /// The duel as it ended.
  final DuelGameEntity game;
}

/// A player won.
final class DuelFinished extends DuelState {
  /// Creates the state.
  const DuelFinished({
    required this.lineup,
    required this.game,
    required this.outcome,
  });

  /// Who played which half.
  final DuelLineup lineup;

  /// The duel as it ended.
  final DuelGameEntity game;

  /// The winner and the XP of each side.
  final DuelOutcome outcome;
}
