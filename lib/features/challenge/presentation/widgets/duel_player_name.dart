import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// The name shown for a duel player.
extension DuelPlayerName on DuelPlayer {
  /// The nickname of a profile, "Invité" for a guest.
  String nameIn(AppLocalizations l10n) => switch (this) {
    ProfileDuelPlayer(:final identity) => identity.nickname,
    GuestDuelPlayer() => l10n.duelGuest,
  };
}
