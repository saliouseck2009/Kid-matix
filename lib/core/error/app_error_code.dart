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

  /// A file is damaged or is not what the app expects.
  invalidFile,

  /// A file was written by a newer version of the app.
  unsupportedVersion,

  /// The person refused a permission the app asked for, such as the
  /// notifications of the daily reminder.
  permissionDenied,

  /// Any failure that has no dedicated code.
  unknown,
}
