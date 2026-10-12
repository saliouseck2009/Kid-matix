import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:meta/meta.dart';

/// How a duel ended: the winner and the XP each side earned.
@immutable
final class DuelOutcome {
  /// Creates the outcome.
  const DuelOutcome({
    required this.winner,
    required this.topXp,
    required this.bottomXp,
    this.isXpSaved = true,
  });

  /// Side that reached the winning score first.
  final DuelSide winner;

  /// XP earned by the player of the top half; 0 for a guest.
  final int topXp;

  /// XP earned by the player of the bottom half; 0 for a guest.
  final int bottomXp;

  /// Whether the XP were saved; `false` when the phone failed to keep
  /// them.
  final bool isXpSaved;

  /// XP earned by the player of [side].
  int xpOf(DuelSide side) => side == DuelSide.top ? topXp : bottomXp;

  /// Returns a copy with the given fields replaced.
  DuelOutcome copyWith({
    DuelSide? winner,
    int? topXp,
    int? bottomXp,
    bool? isXpSaved,
  }) {
    return DuelOutcome(
      winner: winner ?? this.winner,
      topXp: topXp ?? this.topXp,
      bottomXp: bottomXp ?? this.bottomXp,
      isXpSaved: isXpSaved ?? this.isXpSaved,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DuelOutcome &&
            other.winner == winner &&
            other.topXp == topXp &&
            other.bottomXp == bottomXp &&
            other.isXpSaved == isXpSaved;
  }

  @override
  int get hashCode => Object.hash(winner, topXp, bottomXp, isXpSaved);
}
