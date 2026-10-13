import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer.dart';
import 'package:meta/meta.dart';

/// The shop as one player sees it: their coins and every item.
@immutable
final class ShopEntity {
  /// Creates the shop of [player].
  const ShopEntity({
    required this.player,
    required this.balance,
    required this.activeTheme,
    required this.offers,
  });

  /// The player: nickname, avatar worn and color.
  final PlayerIdentity player;

  /// Coins the player can spend: earned minus spent.
  final int balance;

  /// Theme the player applied.
  final AppColorTheme activeTheme;

  /// Every item of the catalog, in its order.
  final List<ShopOffer> offers;

  /// Returns the offers of [kind], in the order of the catalog.
  List<ShopOffer> offersOf(ShopItemKind kind) {
    return offers.where((ShopOffer offer) => offer.item.kind == kind).toList();
  }

  /// Returns the offer of the item [itemId], or `null`.
  ShopOffer? findOffer(String itemId) {
    for (final ShopOffer offer in offers) {
      if (offer.item.id == itemId) return offer;
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ShopEntity &&
            other.player == player &&
            other.balance == balance &&
            other.activeTheme == activeTheme &&
            _sameOffers(other.offers);
  }

  @override
  int get hashCode =>
      Object.hash(player, balance, activeTheme, Object.hashAll(offers));

  @override
  String toString() => 'ShopEntity(${player.id}, $balance coins)';

  bool _sameOffers(List<ShopOffer> others) {
    if (others.length != offers.length) return false;
    for (int i = 0; i < offers.length; i++) {
      if (others[i] != offers[i]) return false;
    }
    return true;
  }
}
