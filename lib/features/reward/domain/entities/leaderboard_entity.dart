import 'package:kid_matix/features/reward/domain/entities/leaderboard_chase.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:meta/meta.dart';

/// The players ranked by the XP they earned this week.
@immutable
final class LeaderboardEntity {
  /// Creates the leaderboard of the week starting at [weekStart], with
  /// [entries] already ranked, the first one first.
  const LeaderboardEntity({required this.entries, required this.weekStart});

  /// Players from first to last; the rank of an entry is its index + 1.
  final List<LeaderboardEntry> entries;

  /// Monday 00:00 of the week ranked, in local time.
  final DateTime weekStart;

  /// Returns the rank of [profileId], from 1, or `null` when absent.
  int? rankOf(String profileId) {
    final int index = _indexOf(profileId);
    return index < 0 ? null : index + 1;
  }

  /// Returns where [profileId] stands against the player above, or
  /// `null` when absent.
  LeaderboardChase? chaseOf(String profileId) {
    final int index = _indexOf(profileId);
    if (index < 0) return null;
    final LeaderboardEntry player = entries[index];
    if (index == 0) {
      return player.weeklyXp > 0
          ? const LeaderboardChaseLeading()
          : const LeaderboardChaseNotStarted();
    }
    final LeaderboardEntry above = entries[index - 1];
    final int missingXp = above.weeklyXp - player.weeklyXp;
    return missingXp > 0
        ? LeaderboardChaseBehind(
            nickname: above.player.nickname,
            missingXp: missingXp,
          )
        : LeaderboardChaseTied(nickname: above.player.nickname);
  }

  /// Returns a copy with the given fields replaced.
  LeaderboardEntity copyWith({
    List<LeaderboardEntry>? entries,
    DateTime? weekStart,
  }) {
    return LeaderboardEntity(
      entries: entries ?? this.entries,
      weekStart: weekStart ?? this.weekStart,
    );
  }

  int _indexOf(String profileId) {
    return entries.indexWhere(
      (LeaderboardEntry entry) => entry.player.id == profileId,
    );
  }
}
