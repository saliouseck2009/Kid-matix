import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:meta/meta.dart';

/// An item of the shop: an avatar or a theme, and its price in coins.
@immutable
final class ShopItem {
  /// Creates the item [key] of [kind], sold for [price] coins.
  const ShopItem({required this.kind, required this.key, required this.price});

  /// What the item changes.
  final ShopItemKind kind;

  /// Stable name of the avatar or the theme, such as `fox` or `ocean`.
  final String key;

  /// Price in coins; 0 for an item every player owns.
  final int price;

  /// Stable identifier of the item, such as `avatar:fox`, stored with
  /// each purchase.
  String get id => '${kind.name}:$key';

  /// Whether every player owns the item without buying it.
  bool get isFree => price == 0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ShopItem &&
            other.kind == kind &&
            other.key == key &&
            other.price == price;
  }

  @override
  int get hashCode => Object.hash(kind, key, price);

  @override
  String toString() => 'ShopItem($id, $price)';
}
