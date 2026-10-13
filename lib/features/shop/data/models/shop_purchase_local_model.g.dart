// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_purchase_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopPurchaseLocalModel _$ShopPurchaseLocalModelFromJson(
  Map<String, dynamic> json,
) => ShopPurchaseLocalModel(
  id: json['id'] as String,
  profileId: json['profile_id'] as String,
  itemId: json['item_id'] as String,
  price: (json['price'] as num).toInt(),
  purchasedAt: (json['purchased_at'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$ShopPurchaseLocalModelToJson(
  ShopPurchaseLocalModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'profile_id': instance.profileId,
  'item_id': instance.itemId,
  'price': instance.price,
  'purchased_at': instance.purchasedAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
