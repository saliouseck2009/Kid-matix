import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';

/// The daily streak: one more day for each day with a completed quiz, by
/// the phone's clock.
///
/// A date that goes back changes nothing. One joker per week, from Monday
/// to Sunday, saves the streak after a single missed day. A lost streak
/// keeps its record.
final class StreakPolicy {
  /// Creates the policy.
  const StreakPolicy();

  /// Days a joker can cover.
  static const int jokerDays = 1;

  /// The streak after a quiz completed at [now].
  StreakEntity afterQuiz({
    required StreakEntity streak,
    required DateTime now,
  }) {
    final DateTime today = dayOf(now);
    final DateTime? last = streak.lastPlayedDay;
    if (last != null && !today.isAfter(last)) return streak;
    final int gap = last == null ? 0 : _daysBetween(last, today);
    final bool usesJoker =
        gap == jokerDays + 1 && _isJokerAvailable(streak, today);
    final int current = gap == 1 || usesJoker ? streak.current + 1 : 1;
    return StreakEntity(
      current: current,
      best: current > streak.best ? current : streak.best,
      lastPlayedDay: today,
      jokerUsedWeek: usesJoker ? mondayOf(today) : streak.jokerUsedWeek,
    );
  }

  /// The streak shown at [now]: kept while it can still go on today,
  /// 0 once lost.
  int currentAt({required StreakEntity streak, required DateTime now}) {
    final DateTime? last = streak.lastPlayedDay;
    if (last == null) return 0;
    final DateTime today = dayOf(now);
    if (!today.isAfter(last)) return streak.current;
    final int gap = _daysBetween(last, today);
    if (gap == 1) return streak.current;
    if (gap == jokerDays + 1 && _isJokerAvailable(streak, today)) {
      return streak.current;
    }
    return 0;
  }

  /// Whether the joker of the week of [now] is still unused.
  bool isJokerAvailable({required StreakEntity streak, required DateTime now}) {
    return _isJokerAvailable(streak, dayOf(now));
  }

  /// Midnight of the day of [time].
  static DateTime dayOf(DateTime time) {
    return DateTime(time.year, time.month, time.day);
  }

  /// Monday of the week of [day].
  static DateTime mondayOf(DateTime day) {
    return DateTime(
      day.year,
      day.month,
      day.day - (day.weekday - DateTime.monday),
    );
  }

  bool _isJokerAvailable(StreakEntity streak, DateTime today) {
    return streak.jokerUsedWeek != mondayOf(today);
  }

  static int _daysBetween(DateTime from, DateTime to) {
    return DateTime.utc(
      to.year,
      to.month,
      to.day,
    ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
  }
}
