import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_local_data_source.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_tables.dart';
import 'package:kid_matix/features/reward/data/models/badge_unlock_local_model.dart';
import 'package:kid_matix/features/reward/data/models/session_reward_local_model.dart';
import 'package:kid_matix/features/reward/data/models/streak_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [RewardLocalDataSource] over the app database.
final class RewardLocalDataSourceImpl implements RewardLocalDataSource {
  /// Creates the data source over [database].
  const RewardLocalDataSourceImpl({required this._database});

  static const String _liveProfile = 'profile_id = ? AND deleted_at IS NULL';

  final AppDatabase _database;

  @override
  Future<DatabaseExecutor> get database => _database.database;

  @override
  Future<StreakLocalModel?> getStreak(
    DatabaseExecutor executor, {
    required String profileId,
  }) async {
    final List<Map<String, Object?>> rows = await executor.query(
      RewardTables.streak,
      where: _liveProfile,
      whereArgs: <Object>[profileId],
    );
    return rows.isEmpty ? null : StreakLocalModel.fromJson(rows.single);
  }

  @override
  Future<List<BadgeUnlockLocalModel>> getBadges(
    DatabaseExecutor executor, {
    required String profileId,
  }) async {
    final List<Map<String, Object?>> rows = await executor.query(
      RewardTables.badgeUnlock,
      where: _liveProfile,
      whereArgs: <Object>[profileId],
      orderBy: 'unlocked_at',
    );
    return rows.map(BadgeUnlockLocalModel.fromJson).toList();
  }

  @override
  Future<int> getLightningAnswers(
    DatabaseExecutor executor, {
    required String profileId,
  }) async {
    final List<Map<String, Object?>> rows = await executor.query(
      RewardTables.rewardStats,
      columns: <String>['lightning_answers'],
      where: _liveProfile,
      whereArgs: <Object>[profileId],
    );
    return rows.isEmpty ? 0 : rows.single['lightning_answers']! as int;
  }

  @override
  Future<int> getXpEarned(
    DatabaseExecutor executor, {
    required String profileId,
    int? from,
    int? to,
  }) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COALESCE(SUM(xp_earned), 0) AS xp '
      'FROM ${RewardTables.sessionReward} '
      'WHERE $_liveProfile AND earned_at >= ? AND earned_at < ?',
      <Object>[profileId, from ?? 0, to ?? _farFuture],
    );
    return rows.single['xp']! as int;
  }

  @override
  Future<SessionRewardLocalModel?> getSessionReward(
    DatabaseExecutor executor, {
    required String sessionId,
  }) async {
    final List<Map<String, Object?>> rows = await executor.query(
      RewardTables.sessionReward,
      where: 'session_id = ? AND deleted_at IS NULL',
      whereArgs: <Object>[sessionId],
    );
    return rows.isEmpty ? null : SessionRewardLocalModel.fromJson(rows.single);
  }

  @override
  Future<void> writeRewards(
    DatabaseExecutor executor, {
    required SessionRewardLocalModel reward,
    required StreakLocalModel streak,
    required int lightningAnswers,
    required List<BadgeUnlockLocalModel> badges,
    required int totalXp,
    required int level,
  }) async {
    final Batch batch = executor.batch()
      ..insert(RewardTables.sessionReward, reward.toJson())
      ..insert(
        RewardTables.streak,
        streak.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )
      ..insert(RewardTables.rewardStats, <String, Object?>{
        'profile_id': reward.profileId,
        'lightning_answers': lightningAnswers,
        'updated_at': reward.updatedAt,
      }, conflictAlgorithm: ConflictAlgorithm.replace)
      ..update(
        RewardTables.profile,
        <String, Object?>{
          'total_xp': totalXp,
          'level': level,
          'last_played_at': reward.earnedAt,
          'updated_at': reward.updatedAt,
        },
        where: 'id = ?',
        whereArgs: <Object>[reward.profileId],
      );
    for (final BadgeUnlockLocalModel badge in badges) {
      batch.insert(
        RewardTables.badgeUnlock,
        badge.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Upper bound of an open time range, in milliseconds since epoch.
  static const int _farFuture = 1 << 52;
}
