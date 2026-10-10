import 'package:kid_matix/features/reward/domain/entities/badge_facts.dart';
import 'package:kid_matix/features/reward/domain/entities/session_reward_input.dart';
import 'package:kid_matix/features/reward/domain/entities/session_reward_outcome.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/xp_gain.dart';
import 'package:kid_matix/features/reward/domain/services/badge_evaluator.dart';
import 'package:kid_matix/features/reward/domain/services/level_policy.dart';
import 'package:kid_matix/features/reward/domain/services/streak_policy.dart';
import 'package:kid_matix/features/reward/domain/services/xp_policy.dart';

/// Every reward of a saved quiz: XP, level, streak, counters and badges.
///
/// An abandoned quiz changes nothing: no XP, no streak, no badge.
final class SessionRewardCalculator {
  /// Creates the calculator.
  const SessionRewardCalculator({
    this._xp = const XpPolicy(),
    this._levels = const LevelPolicy(),
    this._streaks = const StreakPolicy(),
    this._badges = const BadgeEvaluator(),
  });

  final XpPolicy _xp;
  final LevelPolicy _levels;
  final StreakPolicy _streaks;
  final BadgeEvaluator _badges;

  /// The rewards of [input] for a player with [totalXp], [streak],
  /// [lightningAnswers] and the badges [unlocked] before the quiz.
  SessionRewardOutcome calculate({
    required SessionRewardInput input,
    required int totalXp,
    required StreakEntity streak,
    required int lightningAnswers,
    required Set<String> unlocked,
  }) {
    final XpGain xp = _xp.gainOf(
      isCompleted: input.isCompleted,
      correctCount: input.correctCount,
      lightningCount: input.lightningCount,
      questionCount: input.questionCount,
    );
    if (!input.isCompleted) {
      return SessionRewardOutcome(
        xp: xp,
        totalXp: totalXp,
        level: _levels.levelOf(totalXp),
        streak: streak,
        lightningAnswers: lightningAnswers,
        newBadges: const <String>[],
      );
    }
    final StreakEntity newStreak = _streaks.afterQuiz(
      streak: streak,
      now: input.now,
    );
    final int lightning = lightningAnswers + input.lightningCount;
    final String? crowned = input.crownedUnitKey;
    return SessionRewardOutcome(
      xp: xp,
      totalXp: totalXp + xp.total,
      level: _levels.levelOf(totalXp + xp.total),
      streak: newStreak,
      lightningAnswers: lightning,
      newBadges: _badges.newBadges(
        facts: BadgeFacts(
          isStageCompleted: input.isStage,
          isPerfectStage:
              input.isStage &&
              input.questionCount > 0 &&
              input.correctCount >= input.questionCount,
          lightningAnswerCount: lightning,
          streak: newStreak.current,
          crownedUnitKeys: crowned == null ? <String>{} : <String>{crowned},
          masteredItemCount: input.masteredItemCount,
          itemCount: input.itemCount,
          timeAttackScore: input.isTimeAttack ? input.correctCount : 0,
        ),
        unlocked: unlocked,
      ),
    );
  }
}
