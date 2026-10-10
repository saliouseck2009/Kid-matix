import 'package:meta/meta.dart';

/// What a saved quiz brings to the rewards.
@immutable
final class SessionRewardInput {
  /// Creates the input.
  const SessionRewardInput({
    required this.isCompleted,
    required this.correctCount,
    required this.questionCount,
    required this.lightningCount,
    required this.isStage,
    required this.masteredItemCount,
    required this.itemCount,
    required this.now,
    this.crownedUnitKey,
    this.isTimeAttack = false,
  });

  /// Whether the quiz was completed rather than abandoned.
  final bool isCompleted;

  /// Right answers among the scored ones.
  final int correctCount;

  /// Scored questions.
  final int questionCount;

  /// Lightning answers among the scored ones.
  final int lightningCount;

  /// Whether the quiz was a stage of the learning path.
  final bool isStage;

  /// Unit crowned by this quiz, a boss fight won, or `null`.
  final String? crownedUnitKey;

  /// Items of the domain the player has mastered.
  final int masteredItemCount;

  /// Items of the domain.
  final int itemCount;

  /// When the quiz ended.
  final DateTime now;

  /// Whether the quiz was a time attack.
  final bool isTimeAttack;
}
