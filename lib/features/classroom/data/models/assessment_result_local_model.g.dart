// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_result_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentResultLocalModel _$AssessmentResultLocalModelFromJson(
  Map<String, dynamic> json,
) => AssessmentResultLocalModel(
  assessmentId: json['assessment_id'] as String,
  profileId: json['profile_id'] as String,
  takenAt: (json['taken_at'] as num).toInt(),
  wordCount: (json['word_count'] as num).toInt(),
  understoodWordCount: (json['understood_word_count'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$AssessmentResultLocalModelToJson(
  AssessmentResultLocalModel instance,
) => <String, dynamic>{
  'assessment_id': instance.assessmentId,
  'profile_id': instance.profileId,
  'taken_at': instance.takenAt,
  'word_count': instance.wordCount,
  'understood_word_count': instance.understoodWordCount,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
