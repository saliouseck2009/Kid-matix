// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_unlock_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeUnlockLocalModel _$BadgeUnlockLocalModelFromJson(
  Map<String, dynamic> json,
) => BadgeUnlockLocalModel(
  profileId: json['profile_id'] as String,
  badgeKey: json['badge_key'] as String,
  unlockedAt: (json['unlocked_at'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  sessionId: json['session_id'] as String?,
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$BadgeUnlockLocalModelToJson(
  BadgeUnlockLocalModel instance,
) => <String, dynamic>{
  'profile_id': instance.profileId,
  'badge_key': instance.badgeKey,
  'unlocked_at': instance.unlockedAt,
  'session_id': instance.sessionId,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
