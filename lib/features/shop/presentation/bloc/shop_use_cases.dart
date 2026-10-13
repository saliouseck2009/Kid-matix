import 'package:kid_matix/features/shop/domain/usecases/buy_shop_item_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/get_active_theme_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/get_shop_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/use_shop_item_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/watch_shop_changes_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/watch_theme_changes_use_case.dart';

/// Use cases of the shop screens.
final class ShopUseCases {
  /// Groups the use cases.
  const ShopUseCases({
    required this.getShop,
    required this.buy,
    required this.use,
    required this.watchChanges,
    required this.getActiveTheme,
    required this.watchThemeChanges,
  });

  /// Reads the shop of a player.
  final GetShopUseCase getShop;

  /// Buys an item.
  final BuyShopItemUseCase buy;

  /// Wears an avatar or applies a theme.
  final UseShopItemUseCase use;

  /// Tells when the shop may have changed.
  final WatchShopChangesUseCase watchChanges;

  /// Reads the theme a player applied.
  final GetActiveThemeUseCase getActiveTheme;

  /// Tells when the theme may have changed.
  final WatchThemeChangesUseCase watchThemeChanges;
}
