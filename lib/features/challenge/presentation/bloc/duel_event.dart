import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_lineup.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';

/// Something that happens around a duel.
sealed class DuelEvent {
  /// Creates an event.
  const DuelEvent();
}

/// The duel screen opened: the players of the phone are read.
final class DuelOpened extends DuelEvent {
  /// Creates the event.
  const DuelOpened();
}

/// [player] was picked to hold the half [side].
final class DuelPlayerPicked extends DuelEvent {
  /// Creates the event.
  const DuelPlayerPicked({required this.side, required this.player});

  /// Half the player will hold.
  final DuelSide side;

  /// Player picked.
  final DuelPlayer player;
}

/// The two players are ready: the race begins.
final class DuelStarted extends DuelEvent {
  /// Creates the event.
  const DuelStarted({required this.lineup});

  /// Who plays which half.
  final DuelLineup lineup;
}

/// The player of [side] tapped [answer].
final class PlayerAnswered extends DuelEvent {
  /// Creates the event.
  const PlayerAnswered({required this.side, required this.answer});

  /// Half of the player.
  final DuelSide side;

  /// Answer tapped.
  final Answer answer;
}

/// Time passed: the blocks after a mistake shorten.
final class DuelTicked extends DuelEvent {
  /// Creates the event.
  const DuelTicked();
}

/// "Rejouer": a new duel between the same players.
final class DuelRestarted extends DuelEvent {
  /// Creates the event.
  const DuelRestarted();
}

/// The duel was stopped before its end: no XP, back to the choice of the
/// players.
final class DuelAbandoned extends DuelEvent {
  /// Creates the event.
  const DuelAbandoned();
}
