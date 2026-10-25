// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_level_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentLevelLocalModel _$AssessmentLevelLocalModelFromJson(
  Map<String, dynamic> json,
) => AssessmentLevelLocalModel(
  assessmentId: json['assessment_id'] as String,
  profileId: json['profile_id'] as String,
  domainId: json['domain_id'] as String,
  skillCount: (json['skill_count'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  level: (json['level'] as num?)?.toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$AssessmentLevelLocalModelToJson(
  AssessmentLevelLocalModel instance,
) => <String, dynamic>{
  'assessment_id': instance.assessmentId,
  'profile_id': instance.profileId,
  'domain_id': instance.domainId,
  'level': instance.level,
  'skill_count': instance.skillCount,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
