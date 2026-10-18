import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';

/// Every item of the shop, in the order of its grid (lot F21).
///
/// The avatar keys are the names the profile feature stores; the theme
/// keys are the names of [AppColorTheme]. Prices are the owner's choices.
abstract final class ShopCatalog {
  /// The avatars: the ones to buy, cheapest first, then the 12 free ones.
  static const List<ShopItem> avatars = <ShopItem>[
    ShopItem(kind: ShopItemKind.avatar, key: 'fox', price: 80),
    ShopItem(kind: ShopItemKind.avatar, key: 'panda', price: 80),
    ShopItem(kind: ShopItemKind.avatar, key: 'robot', price: 120),
    ShopItem(kind: ShopItemKind.avatar, key: 'alien', price: 150),
    ShopItem(kind: ShopItemKind.avatar, key: 'unicorn', price: 180),
    ShopItem(kind: ShopItemKind.avatar, key: 'dragon', price: 220),
    ShopItem(kind: ShopItemKind.avatar, key: 'ninja', price: 250),
    ShopItem(kind: ShopItemKind.avatar, key: 'king', price: 300),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar1', price: 0),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar2', price: 0),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar3', price: 0),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar4', price: 0),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar5', price: 0),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar6', price: 0),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar7', price: 0),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar8', price: 0),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar9', price: 0),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar10', price: 0),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar11', price: 0),
    ShopItem(kind: ShopItemKind.avatar, key: 'avatar12', price: 0),
  ];

  /// The color themes: the free lavender one, then the ones to buy.
  static const List<ShopItem> themes = <ShopItem>[
    ShopItem(kind: ShopItemKind.theme, key: 'lavender', price: 0),
    ShopItem(kind: ShopItemKind.theme, key: 'ocean', price: 150),
    ShopItem(kind: ShopItemKind.theme, key: 'forest', price: 150),
    ShopItem(kind: ShopItemKind.theme, key: 'sunset', price: 200),
    ShopItem(kind: ShopItemKind.theme, key: 'night', price: 250),
  ];

  /// Every item, avatars first.
  static const List<ShopItem> items = <ShopItem>[...avatars, ...themes];

  /// Returns the item [id], such as `avatar:fox`, or `null` when the shop
  /// sells nothing under that identifier.
  static ShopItem? findById(String id) {
    for (final ShopItem item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Returns the item of [theme].
  static ShopItem themeItemOf(AppColorTheme theme) {
    return themes.firstWhere((ShopItem item) => item.key == theme.name);
  }
}
