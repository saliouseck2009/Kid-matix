/// Which players a leaderboard ranks.
///
/// Version 1.1 is offline and implements [phone] only; [friends] and
/// [world] come with the online mode, behind the same contract.
enum LeaderboardScope {
  /// The players of this phone.
  phone,

  /// The friends of the player, by a group code.
  friends,

  /// Every player.
  world,
}
