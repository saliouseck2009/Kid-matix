// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mascot_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MascotLocalModel _$MascotLocalModelFromJson(Map<String, dynamic> json) =>
    MascotLocalModel(
      profileId: json['profile_id'] as String,
      name: json['name'] as String,
      wornAccessories: json['worn_accessories'] as String,
      celebratedStage: (json['celebrated_stage'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
      deletedAt: (json['deleted_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MascotLocalModelToJson(MascotLocalModel instance) =>
    <String, dynamic>{
      'profile_id': instance.profileId,
      'name': instance.name,
      'worn_accessories': instance.wornAccessories,
      'celebrated_stage': instance.celebratedStage,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };
