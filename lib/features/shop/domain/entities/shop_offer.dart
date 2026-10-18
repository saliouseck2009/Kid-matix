import 'package:kid_matix/features/shop/domain/entities/shop_item.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer_status.dart';
import 'package:meta/meta.dart';

/// An item of the shop as one player sees it.
@immutable
final class ShopOffer {
  /// Creates the offer of [item] in [status]; [missingCoins] for an item
  /// [ShopOfferStatus.tooExpensive].
  const ShopOffer({
    required this.item,
    required this.status,
    this.missingCoins = 0,
  });

  /// Item offered.
  final ShopItem item;

  /// Where the player stands with it.
  final ShopOfferStatus status;

  /// Coins the player still needs to buy it; 0 unless too expensive.
  final int missingCoins;

  /// Whether the player owns the item.
  bool get isOwned =>
      status == ShopOfferStatus.inUse || status == ShopOfferStatus.owned;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ShopOffer &&
            other.item == item &&
            other.status == status &&
            other.missingCoins == missingCoins;
  }

  @override
  int get hashCode => Object.hash(item, status, missingCoins);

  @override
  String toString() => 'ShopOffer(${item.id}, ${status.name})';
}
