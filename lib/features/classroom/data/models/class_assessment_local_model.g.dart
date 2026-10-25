// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_assessment_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassAssessmentLocalModel _$ClassAssessmentLocalModelFromJson(
  Map<String, dynamic> json,
) => ClassAssessmentLocalModel(
  id: json['id'] as String,
  classroomId: json['classroom_id'] as String,
  periodLabel: json['period_label'] as String,
  openedAt: (json['opened_at'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  closedAt: (json['closed_at'] as num?)?.toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$ClassAssessmentLocalModelToJson(
  ClassAssessmentLocalModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'classroom_id': instance.classroomId,
  'period_label': instance.periodLabel,
  'opened_at': instance.openedAt,
  'closed_at': instance.closedAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
