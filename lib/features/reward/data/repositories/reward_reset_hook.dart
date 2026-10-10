import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_tables.dart';
import 'package:sqflite/sqflite.dart';

/// Erases the rewards of a player: XP, streak, badges and counters; the
/// XP and level copied on the profile go back to the start.
final class RewardResetHook implements ProgressResetHook {
  /// Creates the hook.
  const RewardResetHook();

  static const int _firstLevel = 1;

  @override
  Future<List<String>> reset(
    Transaction transaction, {
    required String profileId,
  }) async {
    for (final String table in <String>[
      RewardTables.sessionReward,
      RewardTables.streak,
      RewardTables.badgeUnlock,
      RewardTables.rewardStats,
    ]) {
      await transaction.delete(
        table,
        where: 'profile_id = ?',
        whereArgs: <Object>[profileId],
      );
    }
    await transaction.update(
      RewardTables.profile,
      <String, Object?>{'total_xp': 0, 'level': _firstLevel},
      where: 'id = ?',
      whereArgs: <Object>[profileId],
    );
    return const <String>[
      RewardTables.sessionReward,
      RewardTables.streak,
      RewardTables.badgeUnlock,
      RewardTables.profile,
    ];
  }
}
