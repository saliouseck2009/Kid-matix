import 'package:meta/meta.dart';

/// An item a player bought, with the coins it cost then.
@immutable
final class ShopPurchase {
  /// Creates the purchase of [itemId] for [price] coins at [purchasedAt].
  const ShopPurchase({
    required this.itemId,
    required this.price,
    required this.purchasedAt,
  });

  /// Identifier of the item, such as `avatar:fox`.
  final String itemId;

  /// Coins paid; a later change of the price leaves the balance as it is.
  final int price;

  /// When the item was bought.
  final DateTime purchasedAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ShopPurchase &&
            other.itemId == itemId &&
            other.price == price &&
            other.purchasedAt == purchasedAt;
  }

  @override
  int get hashCode => Object.hash(itemId, price, purchasedAt);

  @override
  String toString() => 'ShopPurchase($itemId, $price)';
}
