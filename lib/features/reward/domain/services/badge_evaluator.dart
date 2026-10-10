import 'package:kid_matix/features/reward/domain/entities/badge_facts.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_key.dart';

/// Decides which badges a completed quiz unlocks.
///
/// Survivant comes with lot F12.
final class BadgeEvaluator {
  /// Creates the evaluator.
  const BadgeEvaluator();

  /// Lightning answers of the Éclair badge.
  static const int lightningAnswersForBadge = 20;

  /// Right answers in one time attack of the Sprinter badge.
  static const int timeAttackScoreForBadge = 20;

  /// Streak of the Régulier badge.
  static const int streakForBadge = 7;

  /// The badges [facts] earn that are not in [unlocked] yet, in a stable
  /// order.
  List<String> newBadges({
    required BadgeFacts facts,
    required Set<String> unlocked,
  }) {
    final List<String> earned = <String>[
      if (facts.isStageCompleted) BadgeKey.firstStep,
      if (facts.isPerfectStage) BadgeKey.perfect,
      if (facts.lightningAnswerCount >= lightningAnswersForBadge)
        BadgeKey.lightning,
      if (facts.timeAttackScore >= timeAttackScoreForBadge) BadgeKey.sprinter,
      if (facts.streak >= streakForBadge) BadgeKey.regular,
      for (final String unitKey in facts.crownedUnitKeys)
        BadgeKey.tamerOf(unitKey),
      if (facts.itemCount > 0 && facts.masteredItemCount >= facts.itemCount)
        BadgeKey.allFacts,
    ];
    return earned.where((String key) => !unlocked.contains(key)).toList();
  }
}
