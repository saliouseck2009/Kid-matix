/// Names of the tables of the shop.
abstract final class ShopTables {
  /// Items bought, one row per player and item.
  static const String purchase = 'shop_purchase';

  /// Theme applied, one row per player.
  static const String choice = 'shop_choice';
}
