/// The audio help of a player: the language of the recorded explanations
/// of the math words, or none. A player who never chose has no value
/// (`null`): the help is then in the first pack of `assets/audio/packs.json`.
///
/// A language is the code of an audio pack (`assets/audio/<language>/`),
/// so the code depends on no language in particular.
abstract final class HelpAudio {
  /// Stored when the player turned the audio help off.
  static const String none = 'none';
}
