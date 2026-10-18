/// Where the domain each player last chose on the map is kept.
abstract interface class PathDomainLocalDataSource {
  /// Returns the domain [profileId] last chose, or `null`.
  Future<String?> readDomain({required String profileId});

  /// Keeps [domainId] as the domain [profileId] chose.
  Future<void> writeDomain({
    required String profileId,
    required String domainId,
  });
}
