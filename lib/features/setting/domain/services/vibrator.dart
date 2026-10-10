/// Strength of a vibration.
enum VibrationStrength {
  /// A light tap, after a mistake.
  light,

  /// A firmer tap, for a celebration.
  medium,
}

/// Makes the phone vibrate.
abstract interface class Vibrator {
  /// Vibrates with [strength].
  Future<void> vibrate(VibrationStrength strength);
}
