import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:kid_matix/core/storage/backup_section_reader.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_tables.dart';
import 'package:kid_matix/features/reward/data/models/badge_unlock_local_model.dart';
import 'package:kid_matix/features/reward/data/models/reward_stats_local_model.dart';
import 'package:kid_matix/features/reward/data/models/session_reward_local_model.dart';
import 'package:kid_matix/features/reward/data/models/streak_local_model.dart';
import 'package:kid_matix/features/reward/data/models/xp_award_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// The rewards of a player in a backup file: XP of quizzes and duels,
/// streak, badges and counters. The XP total and the level copied on
/// the profile row travel with it.
final class RewardBackupPart implements ProfileBackupPart {
  /// Creates the part.
  const RewardBackupPart();

  static const String _sessionRewardsKey = 'sessionRewards';
  static const String _xpAwardsKey = 'xpAwards';
  static const String _streakKey = 'streak';
  static const String _badgesKey = 'badges';
  static const String _statsKey = 'stats';

  @override
  String get section => 'reward';

  @override
  Future<Map<String, Object?>> exportSection(
    DatabaseExecutor executor, {
    required String profileId,
  }) async {
    Future<List<Map<String, Object?>>> rowsOf(String table) {
      return executor.query(
        table,
        where: 'profile_id = ?',
        whereArgs: <Object>[profileId],
      );
    }

    return <String, Object?>{
      _sessionRewardsKey: await rowsOf(RewardTables.sessionReward),
      _xpAwardsKey: await rowsOf(RewardTables.xpAward),
      _streakKey: (await rowsOf(RewardTables.streak)).firstOrNull,
      _badgesKey: await rowsOf(RewardTables.badgeUnlock),
      _statsKey: (await rowsOf(RewardTables.rewardStats)).firstOrNull,
    };
  }

  @override
  Future<List<String>> importSection(
    Transaction transaction, {
    required Map<String, Object?> content,
    required BackupIdMap ids,
  }) async {
    final Batch batch = transaction.batch();
    _addXp(batch, content, ids);
    _addStreakAndStats(batch, content, ids);
    for (final BadgeUnlockLocalModel badge in BackupSectionReader.readRows(
      content,
      key: _badgesKey,
      fromJson: BadgeUnlockLocalModel.fromJson,
    )) {
      final String? sessionId = badge.sessionId;
      batch.insert(RewardTables.badgeUnlock, <String, Object?>{
        ...badge.toJson(),
        'profile_id': ids.profileId,
        'session_id': sessionId == null ? null : ids.remap(sessionId),
      });
    }
    await batch.commit(noResult: true);
    return const <String>[
      RewardTables.sessionReward,
      RewardTables.xpAward,
      RewardTables.streak,
      RewardTables.badgeUnlock,
      RewardTables.rewardStats,
    ];
  }

  void _addXp(Batch batch, Map<String, Object?> content, BackupIdMap ids) {
    for (final SessionRewardLocalModel reward in BackupSectionReader.readRows(
      content,
      key: _sessionRewardsKey,
      fromJson: SessionRewardLocalModel.fromJson,
    )) {
      batch.insert(RewardTables.sessionReward, <String, Object?>{
        ...reward.toJson(),
        'session_id': ids.remap(reward.sessionId),
        'profile_id': ids.profileId,
      });
    }
    for (final XpAwardLocalModel award in BackupSectionReader.readRows(
      content,
      key: _xpAwardsKey,
      fromJson: XpAwardLocalModel.fromJson,
    )) {
      batch.insert(RewardTables.xpAward, <String, Object?>{
        ...award.toJson(),
        'id': ids.remap(award.id),
        'profile_id': ids.profileId,
      });
    }
  }

  void _addStreakAndStats(
    Batch batch,
    Map<String, Object?> content,
    BackupIdMap ids,
  ) {
    final StreakLocalModel? streak = BackupSectionReader.readRow(
      content,
      key: _streakKey,
      fromJson: StreakLocalModel.fromJson,
    );
    if (streak != null) {
      batch.insert(RewardTables.streak, <String, Object?>{
        ...streak.toJson(),
        'profile_id': ids.profileId,
      });
    }
    final RewardStatsLocalModel? stats = BackupSectionReader.readRow(
      content,
      key: _statsKey,
      fromJson: RewardStatsLocalModel.fromJson,
    );
    if (stats != null) {
      batch.insert(RewardTables.rewardStats, <String, Object?>{
        ...stats.toJson(),
        'profile_id': ids.profileId,
      });
    }
  }
}
