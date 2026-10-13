import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_purchase.dart';

/// The purchases of each player and the theme they applied.
abstract interface class ShopRepository {
  /// Returns the purchases of [profileId], oldest first.
  Future<DataState<List<ShopPurchase>>> getPurchases({
    required String profileId,
  });

  /// Saves [purchase] for [profileId].
  ///
  /// Fails with a `ConflictException` when the item is already bought.
  Future<DataState<void>> addPurchase({
    required String profileId,
    required ShopPurchase purchase,
  });

  /// Returns the theme [profileId] applied, lavender before any choice.
  Future<DataState<AppColorTheme>> getActiveTheme({required String profileId});

  /// Applies [theme] for [profileId].
  Future<DataState<void>> saveActiveTheme({
    required String profileId,
    required AppColorTheme theme,
  });

  /// Emits an event each time a purchase or a theme changes.
  Stream<void> watchChanges();
}
