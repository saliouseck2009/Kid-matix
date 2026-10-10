import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';

/// Stars of a stage: 1 from 60 % of right answers, 2 from 80 %, 3 for a
/// perfect score. A defeated boss earns at least 1 star, a boss that fled
/// none.
final class StarPolicy {
  /// Creates the policy.
  const StarPolicy();

  /// Most stars of a stage.
  static const int maxStars = 3;

  /// Share of right answers that earns 1 star, in percent.
  static const int oneStarPercent = 60;

  /// Share of right answers that earns 2 stars, in percent.
  static const int twoStarsPercent = 80;

  /// Stars of a quiz played for [stage]; [isBossDefeated] tells how a boss
  /// fight ended.
  int starsForStage({
    required StageKind stage,
    required int correctCount,
    required int questionCount,
    bool isBossDefeated = false,
  }) {
    final int stars = starsFor(
      correctCount: correctCount,
      questionCount: questionCount,
    );
    if (stage != StageKind.boss) return stars;
    if (!isBossDefeated) return 0;
    return stars < 1 ? 1 : stars;
  }

  /// Stars for [correctCount] right answers out of [questionCount].
  int starsFor({required int correctCount, required int questionCount}) {
    if (questionCount <= 0) return 0;
    if (correctCount >= questionCount) return maxStars;
    final int percent = correctCount * 100 ~/ questionCount;
    if (percent >= twoStarsPercent) return 2;
    if (percent >= oneStarPercent) return 1;
    return 0;
  }
}
