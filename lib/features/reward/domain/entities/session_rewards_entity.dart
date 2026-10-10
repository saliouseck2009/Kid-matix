import 'package:kid_matix/features/reward/domain/entities/player_level.dart';
import 'package:meta/meta.dart';

/// What a completed quiz brought, as the results show it.
@immutable
final class SessionRewardsEntity {
  /// Creates the rewards.
  SessionRewardsEntity({
    required this.xpEarned,
    required this.levelBefore,
    required this.levelAfter,
    required List<String> newBadges,
  }) : newBadges = List<String>.unmodifiable(newBadges);

  /// No reward: an abandoned quiz.
  const SessionRewardsEntity.none({required PlayerLevel level})
    : xpEarned = 0,
      levelBefore = level,
      levelAfter = level,
      newBadges = const <String>[];

  /// XP earned.
  final int xpEarned;

  /// Level before the quiz.
  final PlayerLevel levelBefore;

  /// Level after the quiz.
  final PlayerLevel levelAfter;

  /// Keys of the badges the quiz unlocked.
  final List<String> newBadges;

  /// Whether the quiz made the player reach a new level.
  bool get isLevelUp => levelAfter.level > levelBefore.level;
}
