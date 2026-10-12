// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_award_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XpAwardLocalModel _$XpAwardLocalModelFromJson(Map<String, dynamic> json) =>
    XpAwardLocalModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      sourceKey: json['source_key'] as String,
      xpEarned: (json['xp_earned'] as num).toInt(),
      earnedAt: (json['earned_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
      deletedAt: (json['deleted_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$XpAwardLocalModelToJson(XpAwardLocalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profile_id': instance.profileId,
      'source_key': instance.sourceKey,
      'xp_earned': instance.xpEarned,
      'earned_at': instance.earnedAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };
