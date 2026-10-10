/// How a quiz session ended; stored by [name].
enum QuizSessionStatus {
  /// Every question was answered; rewards are given.
  completed,

  /// The player left before the end; the answers given still count for
  /// mastery, but no reward is given.
  abandoned,
}
