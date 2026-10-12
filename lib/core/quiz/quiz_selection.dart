/// How the questions of a quiz are chosen among its items.
enum QuizSelection {
  /// The mastery engine draws them: missed facts first, then low boxes
  /// more often, each with the formats fit for its box.
  mastery,

  /// Every item once, in the given order.
  inOrder,

  /// Every item once, in a random order.
  shuffled,

  /// The mastery engine picks the items to review: the overdue first,
  /// then the least known, each once, with the formats fit for its box.
  review,

  /// The mastery engine asks the player's monsters, the facts missed
  /// again and again, each twice, then completes like a review.
  monsterHunt,
}
