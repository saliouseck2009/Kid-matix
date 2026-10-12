/// The game a challenge code replays.
enum ChallengeCodeMode {
  /// A free training without a timer.
  training,

  /// A free training with a timer on each question.
  timedTraining,

  /// A time attack: 60 seconds, multiple choice.
  timeAttack;

  /// Whether the game is a free training, with or without a timer.
  bool get isTraining => this != timeAttack;
}
