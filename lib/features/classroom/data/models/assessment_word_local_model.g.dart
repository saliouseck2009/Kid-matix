// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_word_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentWordLocalModel _$AssessmentWordLocalModelFromJson(
  Map<String, dynamic> json,
) => AssessmentWordLocalModel(
  assessmentId: json['assessment_id'] as String,
  profileId: json['profile_id'] as String,
  itemKey: json['item_key'] as String,
  isUnderstood: const SqliteBoolConverter().fromJson(
    (json['is_understood'] as num).toInt(),
  ),
  updatedAt: (json['updated_at'] as num).toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$AssessmentWordLocalModelToJson(
  AssessmentWordLocalModel instance,
) => <String, dynamic>{
  'assessment_id': instance.assessmentId,
  'profile_id': instance.profileId,
  'item_key': instance.itemKey,
  'is_understood': const SqliteBoolConverter().toJson(instance.isUnderstood),
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
