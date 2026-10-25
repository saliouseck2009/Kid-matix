// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_answer_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassAnswerLocalModel _$ClassAnswerLocalModelFromJson(
  Map<String, dynamic> json,
) => ClassAnswerLocalModel(
  sessionId: json['session_id'] as String,
  position: (json['position'] as num).toInt(),
  itemKey: json['item_key'] as String,
  isCorrect: const SqliteBoolConverter().fromJson(
    (json['is_correct'] as num).toInt(),
  ),
  isRetry: const SqliteBoolConverter().fromJson(
    (json['is_retry'] as num).toInt(),
  ),
  updatedAt: (json['updated_at'] as num).toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$ClassAnswerLocalModelToJson(
  ClassAnswerLocalModel instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'position': instance.position,
  'item_key': instance.itemKey,
  'is_correct': const SqliteBoolConverter().toJson(instance.isCorrect),
  'is_retry': const SqliteBoolConverter().toJson(instance.isRetry),
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
