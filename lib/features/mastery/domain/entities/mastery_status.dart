/// What the player is shown about an item, derived from its box.
enum MasteryStatus {
  /// Box 0: never presented.
  notSeen,

  /// Box 1: missed lately, comes back the next day.
  toReview,

  /// Boxes 2 and 3.
  inProgress,

  /// Box 4, or box 5 while answers are still slow.
  acquired,

  /// Box 5 with a median answer time under 3 seconds.
  mastered,
}
