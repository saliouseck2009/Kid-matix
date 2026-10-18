/// How the questions of a quiz are read aloud for its player.
enum ReadAloudMode {
  /// No voice is installed for the language: nothing is read and the
  /// listen button is hidden, without any message.
  unavailable,

  /// A voice is installed: the player hears a question by tapping the
  /// listen button.
  onRequest,

  /// A voice is installed and the player asked for every new question to
  /// be read by itself ("Lire les questions à voix haute").
  automatic,
}
