import 'package:kid_matix/core/quiz/learning_domain_ids.dart';

/// Rules of the duel on one phone (owner's choices, lot F14).
abstract final class DuelRules {
  /// Domain the questions come from.
  static const String domainId = LearningDomainIds.multiplication;

  /// Right answers that win the duel.
  static const int winningScore = 10;

  /// How long a wrong answer blocks the buttons of its player.
  static const Duration wrongAnswerBlock = Duration(seconds: 2);

  /// XP a player of the phone earns per right answer.
  static const int xpPerRightAnswer = 10;

  /// XP the winner earns on top of their right answers.
  static const int winnerBonusXp = 20;

  /// Source of the XP of a duel, kept with them.
  static const String xpSourceKey = 'duel';
}
