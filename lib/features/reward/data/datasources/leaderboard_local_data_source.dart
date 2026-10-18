/// XP of every player of the phone, read from the local database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository
/// turns them into typed failures.
abstract interface class LeaderboardLocalDataSource {
  /// Returns the XP each player earned from [from], included, to [to],
  /// excluded, in milliseconds since epoch, quizzes and awards together,
  /// by profile id; a player without XP in the range is absent.
  Future<Map<String, int>> getXpByProfile({
    required int from,
    required int to,
  });
}
