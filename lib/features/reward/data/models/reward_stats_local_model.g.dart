// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_stats_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardStatsLocalModel _$RewardStatsLocalModelFromJson(
  Map<String, dynamic> json,
) => RewardStatsLocalModel(
  profileId: json['profile_id'] as String,
  lightningAnswers: (json['lightning_answers'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$RewardStatsLocalModelToJson(
  RewardStatsLocalModel instance,
) => <String, dynamic>{
  'profile_id': instance.profileId,
  'lightning_answers': instance.lightningAnswers,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
