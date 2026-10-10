import 'package:kid_matix/features/reward/domain/entities/player_level.dart';

/// Levels: going from level N to level N + 1 takes 100 × N XP, so level 2
/// starts at 100 XP, level 3 at 300, level 4 at 600.
final class LevelPolicy {
  /// Creates the policy.
  const LevelPolicy();

  /// XP from level N to N + 1, per N.
  static const int xpPerLevelStep = 100;

  /// The level of a player who earned [totalXp] XP.
  PlayerLevel levelOf(int totalXp) {
    int level = 1;
    int start = 0;
    while (totalXp >= start + level * xpPerLevelStep) {
      start += level * xpPerLevelStep;
      level++;
    }
    return PlayerLevel(
      level: level,
      xpIntoLevel: totalXp - start,
      xpForNextLevel: level * xpPerLevelStep,
    );
  }
}
