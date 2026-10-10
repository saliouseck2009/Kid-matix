// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_progress_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StageProgressLocalModel _$StageProgressLocalModelFromJson(
  Map<String, dynamic> json,
) => StageProgressLocalModel(
  profileId: json['profile_id'] as String,
  domainId: json['domain_id'] as String,
  unitKey: json['unit_key'] as String,
  stage: $enumDecode(_$StageKindEnumMap, json['stage']),
  bestStars: (json['best_stars'] as num).toInt(),
  bestScore: (json['best_score'] as num).toInt(),
  completedAt: (json['completed_at'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$StageProgressLocalModelToJson(
  StageProgressLocalModel instance,
) => <String, dynamic>{
  'profile_id': instance.profileId,
  'domain_id': instance.domainId,
  'unit_key': instance.unitKey,
  'stage': _$StageKindEnumMap[instance.stage]!,
  'best_stars': instance.bestStars,
  'best_score': instance.bestScore,
  'completed_at': instance.completedAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};

const _$StageKindEnumMap = {
  StageKind.discovery: 'discovery',
  StageKind.training: 'training',
  StageKind.writing: 'writing',
  StageKind.speed: 'speed',
  StageKind.boss: 'boss',
  StageKind.review: 'review',
};
