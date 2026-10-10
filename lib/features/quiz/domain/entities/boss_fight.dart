import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:meta/meta.dart';

/// How a boss fight ended.
enum BossOutcome {
  /// The boss lost all its hit points.
  defeated,

  /// The boss fled after the last question.
  fled,
}

/// The boss of a fight: its hit points and the last blow it took.
///
/// A right answer takes 1 hit point, a lightning one is a critical hit
/// that takes 2; a mistake costs the player nothing. With 12 hit points,
/// 60 % of right answers win the 20 questions of a fight.
@immutable
final class BossFight {
  /// Creates a boss with [remainingHitPoints] left.
  const BossFight({
    this.remainingHitPoints = hitPoints,
    this.lastDamage = 0,
  });

  /// Hit points of a boss.
  static const int hitPoints = 12;

  /// Damage of a right answer.
  static const int hitDamage = 1;

  /// Damage of a lightning answer.
  static const int criticalDamage = 2;

  /// Questions after which a boss still standing flees.
  static const int maxQuestions = 20;

  /// Hit points left.
  final int remainingHitPoints;

  /// Damage of the last answer: 0 after a mistake, the boss strikes back.
  final int lastDamage;

  /// Whether the boss lost all its hit points.
  bool get isDefeated => remainingHitPoints <= 0;

  /// Whether the last answer was a critical hit.
  bool get isLastHitCritical => lastDamage == criticalDamage;

  /// The boss after [answer].
  BossFight hit(QuizAnswerEntity answer) {
    final int damage = !answer.isCorrect
        ? 0
        : answer.isLightning
        ? criticalDamage
        : hitDamage;
    final int left = remainingHitPoints - damage;
    return BossFight(
      remainingHitPoints: left < 0 ? 0 : left,
      lastDamage: damage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BossFight &&
            other.remainingHitPoints == remainingHitPoints &&
            other.lastDamage == lastDamage;
  }

  @override
  int get hashCode => Object.hash(remainingHitPoints, lastDamage);
}
