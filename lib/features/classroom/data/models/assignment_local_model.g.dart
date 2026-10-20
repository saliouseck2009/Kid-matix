// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignmentLocalModel _$AssignmentLocalModelFromJson(
  Map<String, dynamic> json,
) => AssignmentLocalModel(
  id: json['id'] as String,
  classroomId: json['classroom_id'] as String,
  domainId: json['domain_id'] as String,
  unitKey: json['unit_key'] as String,
  createdAt: (json['created_at'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  dueAt: (json['due_at'] as num?)?.toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$AssignmentLocalModelToJson(
  AssignmentLocalModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'classroom_id': instance.classroomId,
  'domain_id': instance.domainId,
  'unit_key': instance.unitKey,
  'due_at': instance.dueAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
