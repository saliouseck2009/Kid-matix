import 'package:kid_matix/features/shop/domain/entities/shop_purchase.dart';
import 'package:kid_matix/features/shop/presentation/shop_pages.dart';

import '../features/shop/helpers/shop_fakes.dart';

/// The shop pages over fakes: a player with 240 coins, the fox bought.
ShopPages buildTestShopPages() {
  final ShopWorld world = ShopWorld(
    totalXp: 3200,
    purchases: <ShopPurchase>[
      ShopPurchase(
        itemId: 'avatar:fox',
        price: 80,
        purchasedAt: DateTime(2026, 10, 12),
      ),
    ],
  );
  return ShopPages(useCases: world.useCases);
}
