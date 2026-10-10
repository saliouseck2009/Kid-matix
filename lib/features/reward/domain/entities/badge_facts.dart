import 'package:meta/meta.dart';

/// What the badges are judged on, once a quiz is completed.
@immutable
final class BadgeFacts {
  /// Creates the facts.
  BadgeFacts({
    required this.isStageCompleted,
    required this.isPerfectStage,
    required this.lightningAnswerCount,
    required this.streak,
    required Set<String> crownedUnitKeys,
    required this.masteredItemCount,
    required this.itemCount,
  }) : crownedUnitKeys = Set<String>.unmodifiable(crownedUnitKeys);

  /// Whether the quiz was a stage of the learning path.
  final bool isStageCompleted;

  /// Whether that stage was completed without a mistake.
  final bool isPerfectStage;

  /// Lightning answers in all, this quiz included.
  final int lightningAnswerCount;

  /// Streak after the quiz.
  final int streak;

  /// Units whose boss is defeated, this quiz included.
  final Set<String> crownedUnitKeys;

  /// Items of the domain mastered.
  final int masteredItemCount;

  /// Items of the domain.
  final int itemCount;
}
