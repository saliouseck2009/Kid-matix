import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';

/// Rules of the weekly leaderboard: the week runs from Monday 00:00 to
/// the next Monday 00:00, local time of the phone, and the players are
/// ranked by XP, then by nickname.
abstract final class LeaderboardPolicy {
  /// Returns Monday 00:00 of the week holding [now], in local time.
  static DateTime weekStartOf(DateTime now) {
    // Built from the calendar fields, so a change of daylight saving time
    // during the week never shifts midnight.
    return DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - DateTime.monday),
    );
  }

  /// Returns Monday 00:00 of the week after the one starting at
  /// [weekStart].
  static DateTime nextWeekStartOf(DateTime weekStart) {
    return DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + DateTime.daysPerWeek,
    );
  }

  /// Returns [entries] ranked: most XP first; equal XP in the
  /// alphabetical order of the nickname, ignoring case.
  static List<LeaderboardEntry> rank(List<LeaderboardEntry> entries) {
    return List<LeaderboardEntry>.of(entries)..sort(_compare);
  }

  static int _compare(LeaderboardEntry first, LeaderboardEntry second) {
    final int byXp = second.weeklyXp.compareTo(first.weeklyXp);
    if (byXp != 0) return byXp;
    final int byName = first.player.nickname.toLowerCase().compareTo(
      second.player.nickname.toLowerCase(),
    );
    if (byName != 0) return byName;
    return first.player.id.compareTo(second.player.id);
  }
}
