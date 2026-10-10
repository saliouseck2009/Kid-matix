// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_reward_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionRewardLocalModel _$SessionRewardLocalModelFromJson(
  Map<String, dynamic> json,
) => SessionRewardLocalModel(
  sessionId: json['session_id'] as String,
  profileId: json['profile_id'] as String,
  xpEarned: (json['xp_earned'] as num).toInt(),
  xpVersion: (json['xp_version'] as num).toInt(),
  earnedAt: (json['earned_at'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$SessionRewardLocalModelToJson(
  SessionRewardLocalModel instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'profile_id': instance.profileId,
  'xp_earned': instance.xpEarned,
  'xp_version': instance.xpVersion,
  'earned_at': instance.earnedAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
