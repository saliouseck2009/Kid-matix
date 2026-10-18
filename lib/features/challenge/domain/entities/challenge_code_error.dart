/// Why a challenge code typed by the child is refused.
enum ChallengeCodeError {
  /// Not a code: wrong length, an unknown character or impossible values.
  malformed,

  /// A character was changed or two were swapped: the check character
  /// does not match.
  altered,

  /// The code comes from a newer app, whose question generator this one
  /// does not know.
  unknownVersion,
}
