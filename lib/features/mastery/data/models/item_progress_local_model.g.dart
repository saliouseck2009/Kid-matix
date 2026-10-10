// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_progress_local_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemProgressLocalModel _$ItemProgressLocalModelFromJson(
  Map<String, dynamic> json,
) => ItemProgressLocalModel(
  profileId: json['profile_id'] as String,
  domainId: json['domain_id'] as String,
  itemKey: json['item_key'] as String,
  presentationCount: (json['presentation_count'] as num).toInt(),
  correctCount: (json['correct_count'] as num).toInt(),
  lastAnswerTimesMs: json['last_answer_times_ms'] as String,
  box: (json['box'] as num).toInt(),
  updatedAt: (json['updated_at'] as num).toInt(),
  nextReviewAt: (json['next_review_at'] as num?)?.toInt(),
  deletedAt: (json['deleted_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$ItemProgressLocalModelToJson(
  ItemProgressLocalModel instance,
) => <String, dynamic>{
  'profile_id': instance.profileId,
  'domain_id': instance.domainId,
  'item_key': instance.itemKey,
  'presentation_count': instance.presentationCount,
  'correct_count': instance.correctCount,
  'last_answer_times_ms': instance.lastAnswerTimesMs,
  'box': instance.box,
  'next_review_at': instance.nextReviewAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};
