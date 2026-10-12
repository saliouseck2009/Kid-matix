import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/reward/data/datasources/leaderboard_local_data_source.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_tables.dart';
import 'package:sqflite/sqflite.dart';

/// [LeaderboardLocalDataSource] over the app database.
final class LeaderboardLocalDataSourceImpl
    implements LeaderboardLocalDataSource {
  /// Creates the data source over [database].
  const LeaderboardLocalDataSourceImpl({required this._database});

  static const String _inRange =
      'deleted_at IS NULL AND earned_at >= ? AND earned_at < ?';

  final AppDatabase _database;

  @override
  Future<Map<String, int>> getXpByProfile({
    required int from,
    required int to,
  }) async {
    final DatabaseExecutor executor = await _database.database;
    // Quiz XP (the reward side of the session journal) and XP earned
    // outside a quiz, such as in a duel, summed per player.
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT profile_id, SUM(xp_earned) AS xp FROM ('
      'SELECT profile_id, xp_earned FROM ${RewardTables.sessionReward} '
      'WHERE $_inRange '
      'UNION ALL '
      'SELECT profile_id, xp_earned FROM ${RewardTables.xpAward} '
      'WHERE $_inRange) GROUP BY profile_id',
      <Object>[from, to, from, to],
    );
    return <String, int>{
      for (final Map<String, Object?> row in rows)
        row['profile_id']! as String: row['xp']! as int,
    };
  }
}
