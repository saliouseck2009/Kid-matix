// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_choice_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopChoiceLocalModel _$ShopChoiceLocalModelFromJson(
  Map<String, dynamic> json,
) => ShopChoiceLocalModel(
  profileId: json['profile_id'] as String,
  themeId: json['theme_id'] as String,
  updatedAt: (json['updated_at'] as num).toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$ShopChoiceLocalModelToJson(
  ShopChoiceLocalModel instance,
) => <String, dynamic>{
  'profile_id': instance.profileId,
  'theme_id': instance.themeId,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
