// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_session_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassSessionLocalModel _$ClassSessionLocalModelFromJson(
  Map<String, dynamic> json,
) => ClassSessionLocalModel(
  id: json['id'] as String,
  profileId: json['profile_id'] as String,
  classroomId: json['classroom_id'] as String,
  domainId: json['domain_id'] as String,
  startedAt: (json['started_at'] as num).toInt(),
  durationMs: (json['duration_ms'] as num).toInt(),
  questionCount: (json['question_count'] as num).toInt(),
  correctCount: (json['correct_count'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$ClassSessionLocalModelToJson(
  ClassSessionLocalModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'profile_id': instance.profileId,
  'classroom_id': instance.classroomId,
  'domain_id': instance.domainId,
  'started_at': instance.startedAt,
  'duration_ms': instance.durationMs,
  'question_count': instance.questionCount,
  'correct_count': instance.correctCount,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
