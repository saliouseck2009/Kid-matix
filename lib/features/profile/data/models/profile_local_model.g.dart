// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileLocalModel _$ProfileLocalModelFromJson(Map<String, dynamic> json) =>
    ProfileLocalModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      normalizedNickname: json['normalized_nickname'] as String,
      avatar: $enumDecode(_$ProfileAvatarEnumMap, json['avatar']),
      color: $enumDecode(_$ProfileColorEnumMap, json['color']),
      totalXp: (json['total_xp'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      createdAt: (json['created_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
      remoteAccountId: json['remote_account_id'] as String?,
      lastPlayedAt: (json['last_played_at'] as num?)?.toInt(),
      deletedAt: (json['deleted_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProfileLocalModelToJson(ProfileLocalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'remote_account_id': instance.remoteAccountId,
      'nickname': instance.nickname,
      'normalized_nickname': instance.normalizedNickname,
      'avatar': _$ProfileAvatarEnumMap[instance.avatar]!,
      'color': _$ProfileColorEnumMap[instance.color]!,
      'total_xp': instance.totalXp,
      'level': instance.level,
      'created_at': instance.createdAt,
      'last_played_at': instance.lastPlayedAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };

const _$ProfileAvatarEnumMap = {
  ProfileAvatar.avatar1: 'avatar1',
  ProfileAvatar.avatar2: 'avatar2',
  ProfileAvatar.avatar3: 'avatar3',
  ProfileAvatar.avatar4: 'avatar4',
  ProfileAvatar.avatar5: 'avatar5',
  ProfileAvatar.avatar6: 'avatar6',
  ProfileAvatar.avatar7: 'avatar7',
  ProfileAvatar.avatar8: 'avatar8',
  ProfileAvatar.avatar9: 'avatar9',
  ProfileAvatar.avatar10: 'avatar10',
  ProfileAvatar.avatar11: 'avatar11',
  ProfileAvatar.avatar12: 'avatar12',
};

const _$ProfileColorEnumMap = {
  ProfileColor.violet: 'violet',
  ProfileColor.green: 'green',
  ProfileColor.yellow: 'yellow',
  ProfileColor.red: 'red',
  ProfileColor.blue: 'blue',
  ProfileColor.pink: 'pink',
};
