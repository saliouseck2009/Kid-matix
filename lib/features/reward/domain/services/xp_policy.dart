import 'package:kid_matix/features/reward/domain/entities/xp_gain.dart';

/// The XP of a completed quiz: 10 per right answer, 5 more per lightning
/// answer, 20 for completing it and 50 more for a perfect score.
///
/// [version] grows whenever a value changes, so XP earned under older
/// rules can be told apart once online mode exists.
final class XpPolicy {
  /// Creates the policy.
  const XpPolicy();

  /// Version of the values below.
  static const int version = 1;

  /// XP of a right answer.
  static const int perRightAnswer = 10;

  /// Extra XP of a lightning answer.
  static const int perLightningAnswer = 5;

  /// XP for completing a quiz.
  static const int perCompletedQuiz = 20;

  /// Extra XP for a quiz without a mistake.
  static const int perPerfectQuiz = 50;

  /// XP earned by a quiz with [correctCount] right answers, of which
  /// [lightningCount] lightning ones, out of [questionCount]; an abandoned
  /// quiz earns nothing.
  XpGain gainOf({
    required bool isCompleted,
    required int correctCount,
    required int lightningCount,
    required int questionCount,
  }) {
    if (!isCompleted) return const XpGain.none();
    return XpGain(
      answers: correctCount * perRightAnswer,
      lightning: lightningCount * perLightningAnswer,
      completion: perCompletedQuiz,
      perfect: questionCount > 0 && correctCount >= questionCount
          ? perPerfectQuiz
          : 0,
    );
  }
}
