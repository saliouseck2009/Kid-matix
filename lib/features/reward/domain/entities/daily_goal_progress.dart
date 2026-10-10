import 'package:meta/meta.dart';

/// XP earned today against the daily goal.
@immutable
final class DailyGoalProgress {
  /// Creates the progress.
  const DailyGoalProgress({required this.earnedXp, required this.goalXp});

  /// XP earned today.
  final int earnedXp;

  /// XP of the daily goal.
  final int goalXp;

  /// Whether the goal is reached.
  bool get isReached => earnedXp >= goalXp;

  /// Share of the goal reached, from 0 to 1.
  double get progress => goalXp <= 0 ? 1 : (earnedXp / goalXp).clamp(0, 1);
}
