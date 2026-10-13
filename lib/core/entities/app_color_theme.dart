/// A color theme of the app, applied for one player (lot F21).
///
/// Every player starts with [lavender], the colors of the design; the
/// others are unlocked in the shop. Stored in the database by [name];
/// only the theme of `core/theme` knows the colors of each one.
enum AppColorTheme {
  /// Lavender and violet, the colors of the design; free.
  lavender,

  /// Blues of the sea.
  ocean,

  /// Greens of the woods.
  forest,

  /// Oranges of a sunset.
  sunset,

  /// A dark theme: light text on a deep blue night.
  night,
}
