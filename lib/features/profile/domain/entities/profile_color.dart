/// Color a player picks for their avatar.
///
/// The domain only names the choice; the presentation layer maps it to the
/// design color. Stored in the database by [name].
enum ProfileColor {
  /// Brand violet, the default choice.
  violet,

  /// Green.
  green,

  /// Yellow.
  yellow,

  /// Red.
  red,

  /// Blue.
  blue,

  /// Pink.
  pink,
}
