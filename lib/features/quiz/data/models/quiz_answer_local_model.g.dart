// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_answer_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizAnswerLocalModel _$QuizAnswerLocalModelFromJson(
  Map<String, dynamic> json,
) => QuizAnswerLocalModel(
  sessionId: json['session_id'] as String,
  position: (json['position'] as num).toInt(),
  itemKey: json['item_key'] as String,
  questionTypeId: json['question_type_id'] as String,
  isCorrect: const SqliteBoolConverter().fromJson(
    (json['is_correct'] as num).toInt(),
  ),
  isTimedOut: const SqliteBoolConverter().fromJson(
    (json['is_timed_out'] as num).toInt(),
  ),
  isRetry: const SqliteBoolConverter().fromJson(
    (json['is_retry'] as num).toInt(),
  ),
  answerTimeMs: (json['answer_time_ms'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$QuizAnswerLocalModelToJson(
  QuizAnswerLocalModel instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'position': instance.position,
  'item_key': instance.itemKey,
  'question_type_id': instance.questionTypeId,
  'is_correct': const SqliteBoolConverter().toJson(instance.isCorrect),
  'is_timed_out': const SqliteBoolConverter().toJson(instance.isTimedOut),
  'is_retry': const SqliteBoolConverter().toJson(instance.isRetry),
  'answer_time_ms': instance.answerTimeMs,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
