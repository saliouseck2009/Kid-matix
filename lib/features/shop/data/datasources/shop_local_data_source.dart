import 'package:kid_matix/features/shop/data/models/shop_choice_local_model.dart';
import 'package:kid_matix/features/shop/data/models/shop_purchase_local_model.dart';

/// Shop rows stored in the local SQLite database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository
/// turns them into typed failures.
abstract interface class ShopLocalDataSource {
  /// Returns the purchases of [profileId], oldest first.
  Future<List<ShopPurchaseLocalModel>> getPurchases({
    required String profileId,
  });

  /// Inserts [purchase]; throws when its player already bought the item.
  Future<void> insertPurchase({required ShopPurchaseLocalModel purchase});

  /// Returns the theme row of [profileId], or `null`.
  Future<ShopChoiceLocalModel?> getChoice({required String profileId});

  /// Inserts [choice], replacing the row of its player.
  Future<void> upsertChoice({required ShopChoiceLocalModel choice});
}
