// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placement_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlacementLocalModel _$PlacementLocalModelFromJson(Map<String, dynamic> json) =>
    PlacementLocalModel(
      profileId: json['profile_id'] as String,
      domainId: json['domain_id'] as String,
      unitKey: json['unit_key'] as String,
      completedAt: (json['completed_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
      deletedAt: (json['deleted_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PlacementLocalModelToJson(
  PlacementLocalModel instance,
) => <String, dynamic>{
  'profile_id': instance.profileId,
  'domain_id': instance.domainId,
  'unit_key': instance.unitKey,
  'completed_at': instance.completedAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
