/// How the per-question timer behaves for a player.
enum TimerMode {
  /// Regular time limits.
  normal,

  /// Time limits multiplied by 1.5.
  relaxed,

  /// No visible timer; answer time is still measured.
  off,
}
