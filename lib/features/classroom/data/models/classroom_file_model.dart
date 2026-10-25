import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_result_file_model.dart';
import 'package:kid_matix/features/classroom/data/models/assignment_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_assessment_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_pupil_file_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_session_file_model.dart';
import 'package:kid_matix/features/classroom/data/models/classroom_local_model.dart';

part 'classroom_file_model.g.dart';

/// A class file (`.kidmatix`, JSON in UTF-8), versioned like the backups
/// of F20: `format` `kidmatix-class`, `version`, `exportedAt` (ISO 8601,
/// UTC), `appVersion`, then the class, its pupils, its assignments and
/// the sessions of its pupils. Rows keep the database column names.
///
/// Version 2 (F31) adds the assessments of the class and the results of
/// its pupils in them (`assessments`, `assessmentResults`). A version 1
/// file reads as a version 2 file without assessments; an app that only
/// knows version 1 refuses a version 2 file instead of losing them.
@JsonSerializable(explicitToJson: true)
final class ClassroomFileModel {
  /// Creates the file content.
  const ClassroomFileModel({
    required this.format,
    required this.version,
    required this.exportedAt,
    required this.appVersion,
    required this.classroom,
    this.pupils = const <ClassPupilFileModel>[],
    this.assignments = const <AssignmentLocalModel>[],
    this.sessions = const <ClassSessionFileModel>[],
    this.assessments = const <ClassAssessmentLocalModel>[],
    this.assessmentResults = const <AssessmentResultFileModel>[],
  });

  /// Reads the content of a class file.
  factory ClassroomFileModel.fromJson(Map<String, Object?> json) =>
      _$ClassroomFileModelFromJson(json);

  /// Value of [format] of every class file.
  static const String formatName = 'kidmatix-class';

  /// Version written by this app; it goes up whenever an older app would
  /// lose data reading a newer file.
  static const int currentVersion = 2;

  /// Kind of file, [formatName].
  final String format;

  /// Version of the format.
  final int version;

  /// When the file was written, ISO 8601 in UTC.
  final String exportedAt;

  /// Version of the app that wrote it.
  final String appVersion;

  /// The class row.
  final ClassroomLocalModel classroom;

  /// Its pupils.
  final List<ClassPupilFileModel> pupils;

  /// Its assignment rows.
  final List<AssignmentLocalModel> assignments;

  /// The sessions of its pupils, with their answers.
  final List<ClassSessionFileModel> sessions;

  /// Its assessment rows (version 2).
  final List<ClassAssessmentLocalModel> assessments;

  /// The results of its pupils in them (version 2).
  final List<AssessmentResultFileModel> assessmentResults;

  /// Returns the content written in the file.
  Map<String, Object?> toJson() => _$ClassroomFileModelToJson(this);
}
