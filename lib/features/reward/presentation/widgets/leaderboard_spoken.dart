import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// What a screen reader says for [entry], ranked [rank]; [isActive] when
/// it is the player looking at the screen.
String describeLeaderboardEntry(
  AppLocalizations l10n, {
  required LeaderboardEntry entry,
  required int rank,
  required bool isActive,
}) {
  return isActive
      ? l10n.leaderboardEntryYouSpoken(
          entry.player.nickname,
          rank,
          entry.weeklyXp,
        )
      : l10n.leaderboardEntrySpoken(
          entry.player.nickname,
          rank,
          entry.weeklyXp,
        );
}
