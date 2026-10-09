// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_settings_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileSettingsLocalModel _$ProfileSettingsLocalModelFromJson(
  Map<String, dynamic> json,
) => ProfileSettingsLocalModel(
  profileId: json['profile_id'] as String,
  timerMode: $enumDecode(_$TimerModeEnumMap, json['timer_mode']),
  dailyGoalXp: (json['daily_goal_xp'] as num).toInt(),
  isSoundEnabled: const SqliteBoolConverter().fromJson(
    (json['is_sound_enabled'] as num).toInt(),
  ),
  isVibrationEnabled: const SqliteBoolConverter().fromJson(
    (json['is_vibration_enabled'] as num).toInt(),
  ),
  isReducedMotionEnabled: const SqliteBoolConverter().fromJson(
    (json['is_reduced_motion_enabled'] as num).toInt(),
  ),
  isEverythingUnlocked: const SqliteBoolConverter().fromJson(
    (json['is_everything_unlocked'] as num).toInt(),
  ),
  updatedAt: (json['updated_at'] as num).toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProfileSettingsLocalModelToJson(
  ProfileSettingsLocalModel instance,
) => <String, dynamic>{
  'profile_id': instance.profileId,
  'timer_mode': _$TimerModeEnumMap[instance.timerMode]!,
  'daily_goal_xp': instance.dailyGoalXp,
  'is_sound_enabled': const SqliteBoolConverter().toJson(
    instance.isSoundEnabled,
  ),
  'is_vibration_enabled': const SqliteBoolConverter().toJson(
    instance.isVibrationEnabled,
  ),
  'is_reduced_motion_enabled': const SqliteBoolConverter().toJson(
    instance.isReducedMotionEnabled,
  ),
  'is_everything_unlocked': const SqliteBoolConverter().toJson(
    instance.isEverythingUnlocked,
  ),
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};

const _$TimerModeEnumMap = {
  TimerMode.normal: 'normal',
  TimerMode.relaxed: 'relaxed',
  TimerMode.off: 'off',
};
