/// Why a typed nickname cannot be used.
enum NicknameError {
  /// Fewer characters than the minimum.
  tooShort,

  /// More characters than the maximum.
  tooLong,

  /// A character other than a letter, a digit or a space.
  invalidCharacters,
}
