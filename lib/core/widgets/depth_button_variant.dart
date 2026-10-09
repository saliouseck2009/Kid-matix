/// Visual weight of a `DepthButton`.
enum DepthButtonVariant {
  /// Filled with the main action color; one per screen at most.
  primary,

  /// White with an outline, for the alternative action.
  secondary,

  /// Green, to go on after a right answer.
  success,

  /// Red, to go on after a wrong answer.
  danger,
}
