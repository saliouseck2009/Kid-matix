/// A half of the duel screen, and the player who holds it.
enum DuelSide {
  /// The half turned upside down, for the player across the table.
  top,

  /// The half read the right way up.
  bottom;

  /// The side of the opponent.
  DuelSide get opponent => this == top ? bottom : top;
}
