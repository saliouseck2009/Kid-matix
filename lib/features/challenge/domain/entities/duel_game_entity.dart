import 'package:kid_matix/features/challenge/domain/entities/duel_contender.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:meta/meta.dart';

/// A duel being played: both contenders and the score that wins.
@immutable
final class DuelGameEntity {
  /// Creates the duel.
  const DuelGameEntity({
    required this.top,
    required this.bottom,
    required this.winningScore,
  });

  /// Player of the upside-down half.
  final DuelContender top;

  /// Player of the half read the right way up.
  final DuelContender bottom;

  /// Right answers that win the duel.
  final int winningScore;

  /// The contender of [side].
  DuelContender of(DuelSide side) => side == DuelSide.top ? top : bottom;

  /// The side that reached [winningScore], or `null` while both race.
  DuelSide? get winner {
    if (top.score >= winningScore) return DuelSide.top;
    if (bottom.score >= winningScore) return DuelSide.bottom;
    return null;
  }

  /// Whether a player has won.
  bool get isOver => winner != null;

  /// Whether a player's buttons are blocked.
  bool get hasBlockedContender => top.isBlocked || bottom.isBlocked;

  /// Returns a copy where [contender] holds [side].
  DuelGameEntity withContender(DuelSide side, DuelContender contender) {
    return copyWith(
      top: side == DuelSide.top ? contender : null,
      bottom: side == DuelSide.bottom ? contender : null,
    );
  }

  /// Returns a copy with the given fields replaced.
  DuelGameEntity copyWith({
    DuelContender? top,
    DuelContender? bottom,
    int? winningScore,
  }) {
    return DuelGameEntity(
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      winningScore: winningScore ?? this.winningScore,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DuelGameEntity &&
            other.top == top &&
            other.bottom == bottom &&
            other.winningScore == winningScore;
  }

  @override
  int get hashCode => Object.hash(top, bottom, winningScore);
}
