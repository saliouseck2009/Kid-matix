import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_purchase.dart';

part 'shop_purchase_local_model.g.dart';

/// Row of the `shop_purchase` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class ShopPurchaseLocalModel {
  /// Creates a row with every column given.
  const ShopPurchaseLocalModel({
    required this.id,
    required this.profileId,
    required this.itemId,
    required this.price,
    required this.purchasedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Builds the row [id] of [purchase] for [profileId].
  factory ShopPurchaseLocalModel.fromEntity({
    required String id,
    required String profileId,
    required ShopPurchase purchase,
  }) {
    final int purchasedAt = purchase.purchasedAt.millisecondsSinceEpoch;
    return ShopPurchaseLocalModel(
      id: id,
      profileId: profileId,
      itemId: purchase.itemId,
      price: purchase.price,
      purchasedAt: purchasedAt,
      updatedAt: purchasedAt,
    );
  }

  /// Reads a row returned by `sqflite`.
  factory ShopPurchaseLocalModel.fromJson(Map<String, Object?> json) =>
      _$ShopPurchaseLocalModelFromJson(json);

  /// Identifier of the row.
  final String id;

  /// Player.
  final String profileId;

  /// Identifier of the item, such as `avatar:fox`.
  final String itemId;

  /// Coins paid.
  final int price;

  /// When the item was bought, in milliseconds since epoch.
  final int purchasedAt;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$ShopPurchaseLocalModelToJson(this);

  /// Returns the purchase of this row.
  ShopPurchase toEntity() {
    return ShopPurchase(
      itemId: itemId,
      price: price,
      purchasedAt: DateTime.fromMillisecondsSinceEpoch(purchasedAt),
    );
  }
}
