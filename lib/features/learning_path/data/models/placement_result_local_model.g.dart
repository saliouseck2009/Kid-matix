// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placement_result_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlacementResultLocalModel _$PlacementResultLocalModelFromJson(
  Map<String, dynamic> json,
) => PlacementResultLocalModel(
  profileId: json['profile_id'] as String,
  takenAt: (json['taken_at'] as num).toInt(),
  domainId: json['domain_id'] as String,
  level: (json['level'] as num?)?.toInt(),
  skillCount: (json['skill_count'] as num).toInt(),
  unitCount: (json['unit_count'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  startUnitKey: json['start_unit_key'] as String?,
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$PlacementResultLocalModelToJson(
  PlacementResultLocalModel instance,
) => <String, dynamic>{
  'profile_id': instance.profileId,
  'taken_at': instance.takenAt,
  'domain_id': instance.domainId,
  'level': instance.level,
  'skill_count': instance.skillCount,
  'unit_count': instance.unitCount,
  'start_unit_key': instance.startUnitKey,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
