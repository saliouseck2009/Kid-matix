import 'package:kid_matix/features/reward/domain/entities/player_level.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/xp_gain.dart';
import 'package:meta/meta.dart';

/// The rewards of a quiz, ready to be written.
@immutable
final class SessionRewardOutcome {
  /// Creates the outcome.
  SessionRewardOutcome({
    required this.xp,
    required this.totalXp,
    required this.level,
    required this.streak,
    required this.lightningAnswers,
    required List<String> newBadges,
  }) : newBadges = List<String>.unmodifiable(newBadges);

  /// XP earned by the quiz.
  final XpGain xp;

  /// XP of the player after the quiz.
  final int totalXp;

  /// Level of the player after the quiz.
  final PlayerLevel level;

  /// Streak after the quiz.
  final StreakEntity streak;

  /// Lightning answers in all after the quiz.
  final int lightningAnswers;

  /// Keys of the badges the quiz unlocked.
  final List<String> newBadges;
}
