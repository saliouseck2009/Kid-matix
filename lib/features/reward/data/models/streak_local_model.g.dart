// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreakLocalModel _$StreakLocalModelFromJson(Map<String, dynamic> json) =>
    StreakLocalModel(
      profileId: json['profile_id'] as String,
      currentStreak: (json['current_streak'] as num).toInt(),
      bestStreak: (json['best_streak'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
      lastPlayedDay: (json['last_played_day'] as num?)?.toInt(),
      jokerUsedWeek: (json['joker_used_week'] as num?)?.toInt(),
      deletedAt: (json['deleted_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StreakLocalModelToJson(StreakLocalModel instance) =>
    <String, dynamic>{
      'profile_id': instance.profileId,
      'current_streak': instance.currentStreak,
      'best_streak': instance.bestStreak,
      'last_played_day': instance.lastPlayedDay,
      'joker_used_week': instance.jokerUsedWeek,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };
