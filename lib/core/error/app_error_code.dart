/// Stable identifiers of expected failures.
///
/// The domain and data layers never carry display text: the presentation
/// layer resolves a code to a localized message at the point of display.
enum AppErrorCode {
  /// Local storage could not be read or written.
  cache,

  /// The submitted value breaks a business rule.
  validation,

  /// The requested item does not exist.
  notFound,

  /// The operation clashes with existing data.
  conflict,

  /// A business limit is reached, such as the number of profiles.
  limitReached,

  /// Any failure that has no dedicated code.
  unknown,
}
