/// Where a pupil stands on one item (a fact, a word), from their last
/// answers.
enum ItemStanding {
  /// Asked, neither known nor stuck yet.
  learning,

  /// Missed at least twice in the last three answers: « bloqué ».
  struggling,

  /// Right the last three times: acquired.
  acquired,
}
