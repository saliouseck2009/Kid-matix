/// Where the last free training of each player is kept.
abstract interface class TrainingChoiceLocalDataSource {
  /// Returns the source key of the last training of [profileId], or
  /// `null`.
  Future<String?> readChoice({required String profileId});

  /// Keeps [sourceKey] as the last training of [profileId].
  Future<void> writeChoice({
    required String profileId,
    required String sourceKey,
  });
}
