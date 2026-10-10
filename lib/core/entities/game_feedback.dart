/// A moment of the game that the phone marks with a sound or a vibration.
enum GameFeedback {
  /// A right answer: a short bright sound.
  rightAnswer,

  /// A mistake: a soft low sound and a light vibration.
  wrongAnswer,

  /// A celebration (level, badge, mascot growth): a short tune and a
  /// vibration.
  celebration,
}
