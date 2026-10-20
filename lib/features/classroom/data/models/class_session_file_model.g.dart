// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_session_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassSessionFileModel _$ClassSessionFileModelFromJson(
  Map<String, dynamic> json,
) => ClassSessionFileModel(
  session: ClassSessionLocalModel.fromJson(
    json['session'] as Map<String, dynamic>,
  ),
  answers: (json['answers'] as List<dynamic>)
      .map((e) => ClassAnswerLocalModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ClassSessionFileModelToJson(
  ClassSessionFileModel instance,
) => <String, dynamic>{
  'session': instance.session.toJson(),
  'answers': instance.answers.map((e) => e.toJson()).toList(),
};
