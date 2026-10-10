import 'package:kid_matix/features/reward/data/models/badge_unlock_local_model.dart';
import 'package:kid_matix/features/reward/data/models/session_reward_local_model.dart';
import 'package:kid_matix/features/reward/data/models/streak_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// Rewards stored in the local SQLite database.
///
/// Every method takes the [DatabaseExecutor] to use, so the session hook
/// runs them inside the transaction that saves the quiz. Methods throw the
/// `sqflite` exceptions as they come; the repository turns them into
/// typed failures.
abstract interface class RewardLocalDataSource {
  /// The database to use outside a transaction.
  Future<DatabaseExecutor> get database;

  /// Returns the streak row of [profileId], or `null`.
  Future<StreakLocalModel?> getStreak(
    DatabaseExecutor executor, {
    required String profileId,
  });

  /// Returns the badges of [profileId].
  Future<List<BadgeUnlockLocalModel>> getBadges(
    DatabaseExecutor executor, {
    required String profileId,
  });

  /// Returns the lightning answers counted for [profileId].
  Future<int> getLightningAnswers(
    DatabaseExecutor executor, {
    required String profileId,
  });

  /// Returns the XP [profileId] earned from [from], included, to [to],
  /// excluded, in milliseconds since epoch; every XP without bounds.
  Future<int> getXpEarned(
    DatabaseExecutor executor, {
    required String profileId,
    int? from,
    int? to,
  });

  /// Returns the reward of [sessionId], or `null`.
  Future<SessionRewardLocalModel?> getSessionReward(
    DatabaseExecutor executor, {
    required String sessionId,
  });

  /// Writes the rewards of a quiz: its XP, the streak, the counters, the
  /// new badges, and the XP total and level of the profile.
  Future<void> writeRewards(
    DatabaseExecutor executor, {
    required SessionRewardLocalModel reward,
    required StreakLocalModel streak,
    required int lightningAnswers,
    required List<BadgeUnlockLocalModel> badges,
    required int totalXp,
    required int level,
  });
}
