import 'package:meta/meta.dart';

/// The daily streak of a player.
@immutable
final class StreakEntity {
  /// Creates the streak.
  const StreakEntity({
    required this.current,
    required this.best,
    this.lastPlayedDay,
    this.jokerUsedWeek,
  });

  /// Streak of a player who never completed a quiz.
  const StreakEntity.empty()
    : current = 0,
      best = 0,
      lastPlayedDay = null,
      jokerUsedWeek = null;

  /// Days in a row with a completed quiz, as last recorded.
  final int current;

  /// Longest streak ever.
  final int best;

  /// Last day with a completed quiz, at midnight, or `null`.
  final DateTime? lastPlayedDay;

  /// Monday of the week whose joker was used, or `null`.
  final DateTime? jokerUsedWeek;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StreakEntity &&
            other.current == current &&
            other.best == best &&
            other.lastPlayedDay == lastPlayedDay &&
            other.jokerUsedWeek == jokerUsedWeek;
  }

  @override
  int get hashCode => Object.hash(current, best, lastPlayedDay, jokerUsedWeek);

  @override
  String toString() => 'streak $current (best $best, last $lastPlayedDay)';
}
