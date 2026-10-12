/// Whether the leaderboard is shown, kept in the device preferences.
abstract interface class LeaderboardVisibilityLocalDataSource {
  /// Returns the stored value, or `null` when never set.
  Future<bool?> readShown();

  /// Stores [isShown].
  Future<void> writeShown({required bool isShown});
}
