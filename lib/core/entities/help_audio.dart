/// The audio help of a player: the language of the recorded explanations
/// of the math words, or none.
///
/// A language is the code of an audio pack (`assets/audio/<language>/`),
/// so the code depends on no language in particular.
abstract final class HelpAudio {
  /// Stored when the player turned the audio help off.
  static const String none = 'none';

  /// Language of a player who never chose: the pack the app ships. A
  /// language without recording simply shows no button.
  static const String defaultLanguage = 'wo';
}
