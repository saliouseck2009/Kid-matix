// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordLocalModel _$RecordLocalModelFromJson(Map<String, dynamic> json) =>
    RecordLocalModel(
      profileId: json['profile_id'] as String,
      mode: $enumDecode(_$QuizModeEnumMap, json['mode']),
      bestScore: (json['best_score'] as num).toInt(),
      sessionId: json['session_id'] as String,
      achievedAt: (json['achieved_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
      previousBest: (json['previous_best'] as num?)?.toInt(),
      deletedAt: (json['deleted_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecordLocalModelToJson(RecordLocalModel instance) =>
    <String, dynamic>{
      'profile_id': instance.profileId,
      'mode': _$QuizModeEnumMap[instance.mode]!,
      'best_score': instance.bestScore,
      'session_id': instance.sessionId,
      'achieved_at': instance.achievedAt,
      'previous_best': instance.previousBest,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };

const _$QuizModeEnumMap = {
  QuizMode.freeTraining: 'freeTraining',
  QuizMode.path: 'path',
  QuizMode.timeAttack: 'timeAttack',
};
