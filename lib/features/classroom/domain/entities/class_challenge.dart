import 'package:meta/meta.dart';

/// The class challenge of the week: a goal of right answers shared by
/// the whole class, with no individual ranking.
@immutable
final class ClassChallenge {
  /// Creates the challenge of the week starting at [weekStart].
  const ClassChallenge({
    required this.goal,
    required this.correctCount,
    required this.weekStart,
  });

  /// Right answers the class aims at this week.
  final int goal;

  /// Right answers of all the pupils since [weekStart].
  final int correctCount;

  /// Monday 00:00 of the week.
  final DateTime weekStart;

  /// Share of the goal reached, from 0 to 1.
  double get progress {
    if (goal <= 0) return 1;
    return correctCount >= goal ? 1 : correctCount / goal;
  }

  /// Whether the goal is reached.
  bool get isReached => correctCount >= goal;

  /// Returns a copy with the given fields replaced.
  ClassChallenge copyWith({int? goal, int? correctCount, DateTime? weekStart}) {
    return ClassChallenge(
      goal: goal ?? this.goal,
      correctCount: correctCount ?? this.correctCount,
      weekStart: weekStart ?? this.weekStart,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClassChallenge &&
            other.goal == goal &&
            other.correctCount == correctCount &&
            other.weekStart == weekStart;
  }

  @override
  int get hashCode => Object.hash(goal, correctCount, weekStart);
}
