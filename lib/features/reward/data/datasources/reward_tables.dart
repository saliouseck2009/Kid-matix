/// Names of the tables of the rewards.
abstract final class RewardTables {
  /// XP of each completed quiz.
  static const String sessionReward = 'session_reward';

  /// XP earned outside a quiz, such as in a duel.
  static const String xpAward = 'xp_award';

  /// Daily streak per player.
  static const String streak = 'streak';

  /// Badges unlocked per player.
  static const String badgeUnlock = 'badge_unlock';

  /// Counters some badges need, per player.
  static const String rewardStats = 'reward_stats';

  /// Players: their XP total and level are kept in step with the rewards.
  static const String profile = 'profile';
}
