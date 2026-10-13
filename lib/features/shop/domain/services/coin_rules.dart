import 'package:meta/meta.dart';

/// How a player earns the coins of the shop (lot F21, owner's choice):
/// one coin every 10 XP, 20 coins per crown and 10 per badge.
///
/// The coins earned are computed from everything the player won so far,
/// never added one quiz at a time: the XP left over after a quiz count
/// towards the next coin, and a progress reset takes the coins back
/// with the XP, crowns and badges.
@immutable
final class CoinRules {
  /// Creates the rules.
  const CoinRules();

  /// XP that earn one coin.
  static const int xpPerCoin = 10;

  /// Coins earned by each crowned table.
  static const int coinsPerCrown = 20;

  /// Coins earned by each badge.
  static const int coinsPerBadge = 10;

  /// Returns the coins earned with [totalXp] XP, [crowns] crowns and
  /// [badges] badges.
  int earnedFrom({
    required int totalXp,
    required int crowns,
    required int badges,
  }) {
    return totalXp ~/ xpPerCoin +
        crowns * coinsPerCrown +
        badges * coinsPerBadge;
  }
}
