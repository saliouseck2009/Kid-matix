// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassroomLocalModel _$ClassroomLocalModelFromJson(Map<String, dynamic> json) =>
    ClassroomLocalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      weeklyGoal: (json['weekly_goal'] as num).toInt(),
      createdAt: (json['created_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
      deletedAt: (json['deleted_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ClassroomLocalModelToJson(
  ClassroomLocalModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'weekly_goal': instance.weeklyGoal,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
