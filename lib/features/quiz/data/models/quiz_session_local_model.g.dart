// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_session_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizSessionLocalModel _$QuizSessionLocalModelFromJson(
  Map<String, dynamic> json,
) => QuizSessionLocalModel(
  id: json['id'] as String,
  profileId: json['profile_id'] as String,
  domainId: json['domain_id'] as String,
  mode: $enumDecode(_$QuizModeEnumMap, json['mode']),
  status: $enumDecode(_$QuizSessionStatusEnumMap, json['status']),
  startedAt: (json['started_at'] as num).toInt(),
  durationMs: (json['duration_ms'] as num).toInt(),
  questionCount: (json['question_count'] as num).toInt(),
  correctCount: (json['correct_count'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  sourceKey: json['source_key'] as String?,
  bossOutcome: $enumDecodeNullable(_$BossOutcomeEnumMap, json['boss_outcome']),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$QuizSessionLocalModelToJson(
  QuizSessionLocalModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'profile_id': instance.profileId,
  'domain_id': instance.domainId,
  'mode': _$QuizModeEnumMap[instance.mode]!,
  'status': _$QuizSessionStatusEnumMap[instance.status]!,
  'started_at': instance.startedAt,
  'duration_ms': instance.durationMs,
  'question_count': instance.questionCount,
  'correct_count': instance.correctCount,
  'source_key': instance.sourceKey,
  'boss_outcome': _$BossOutcomeEnumMap[instance.bossOutcome],
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};

const _$QuizModeEnumMap = {
  QuizMode.freeTraining: 'freeTraining',
  QuizMode.path: 'path',
  QuizMode.timeAttack: 'timeAttack',
};

const _$QuizSessionStatusEnumMap = {
  QuizSessionStatus.completed: 'completed',
  QuizSessionStatus.abandoned: 'abandoned',
};

const _$BossOutcomeEnumMap = {
  BossOutcome.defeated: 'defeated',
  BossOutcome.fled: 'fled',
};
