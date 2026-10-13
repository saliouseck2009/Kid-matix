import 'package:meta/meta.dart';

/// A player and an item of the shop.
@immutable
final class ShopItemParams {
  /// Creates the parameters for the item [itemId] of [profileId].
  const ShopItemParams({required this.profileId, required this.itemId});

  /// Player.
  final String profileId;

  /// Identifier of the item, such as `avatar:fox`.
  final String itemId;
}
