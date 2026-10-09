/// Remembers which player was active, across app launches.
abstract interface class ActiveProfileLocalDataSource {
  /// Returns the identifier of the last active player, or `null`.
  Future<String?> readActiveProfileId();

  /// Remembers [profileId] as the active player.
  Future<void> writeActiveProfileId({required String profileId});

  /// Forgets the active player.
  Future<void> clearActiveProfileId();
}
