/// Stars of a stage: 1 from 60 % of right answers, 2 from 80 %, 3 for a
/// perfect score.
final class StarPolicy {
  /// Creates the policy.
  const StarPolicy();

  /// Most stars of a stage.
  static const int maxStars = 3;

  /// Share of right answers that earns 1 star, in percent.
  static const int oneStarPercent = 60;

  /// Share of right answers that earns 2 stars, in percent.
  static const int twoStarsPercent = 80;

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
