// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassroomFileModel _$ClassroomFileModelFromJson(
  Map<String, dynamic> json,
) => ClassroomFileModel(
  format: json['format'] as String,
  version: (json['version'] as num).toInt(),
  exportedAt: json['exportedAt'] as String,
  appVersion: json['appVersion'] as String,
  classroom: ClassroomLocalModel.fromJson(
    json['classroom'] as Map<String, dynamic>,
  ),
  pupils:
      (json['pupils'] as List<dynamic>?)
          ?.map((e) => ClassPupilFileModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ClassPupilFileModel>[],
  assignments:
      (json['assignments'] as List<dynamic>?)
          ?.map((e) => AssignmentLocalModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AssignmentLocalModel>[],
  sessions:
      (json['sessions'] as List<dynamic>?)
          ?.map(
            (e) => ClassSessionFileModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ClassSessionFileModel>[],
);

Map<String, dynamic> _$ClassroomFileModelToJson(ClassroomFileModel instance) =>
    <String, dynamic>{
      'format': instance.format,
      'version': instance.version,
      'exportedAt': instance.exportedAt,
      'appVersion': instance.appVersion,
      'classroom': instance.classroom.toJson(),
      'pupils': instance.pupils.map((e) => e.toJson()).toList(),
      'assignments': instance.assignments.map((e) => e.toJson()).toList(),
      'sessions': instance.sessions.map((e) => e.toJson()).toList(),
    };
