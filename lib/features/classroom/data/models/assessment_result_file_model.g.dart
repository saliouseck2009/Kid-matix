// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_result_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentResultFileModel _$AssessmentResultFileModelFromJson(
  Map<String, dynamic> json,
) => AssessmentResultFileModel(
  assessmentId: json['assessment_id'] as String,
  profileId: json['profile_id'] as String,
  takenAt: (json['taken_at'] as num).toInt(),
  levels: (json['levels'] as List<dynamic>)
      .map((e) => e as List<dynamic>)
      .toList(),
  words: (json['words'] as List<dynamic>)
      .map((e) => (e as List<dynamic>).map((e) => e as Object).toList())
      .toList(),
);

Map<String, dynamic> _$AssessmentResultFileModelToJson(
  AssessmentResultFileModel instance,
) => <String, dynamic>{
  'assessment_id': instance.assessmentId,
  'profile_id': instance.profileId,
  'taken_at': instance.takenAt,
  'levels': instance.levels,
  'words': instance.words,
};
