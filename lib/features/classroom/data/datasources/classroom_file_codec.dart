import 'dart:convert';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_result_file_model.dart';
import 'package:kid_matix/features/classroom/data/models/assignment_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_assessment_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_pupil_file_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_session_file_model.dart';
import 'package:kid_matix/features/classroom/data/models/classroom_file_model.dart';
import 'package:kid_matix/features/classroom/data/models/classroom_local_model.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';

/// What [ClassroomFileCodec.encode] needs, in one object for `compute`.
typedef ClassroomFileContent = ({
  ClassroomTransfer transfer,
  DateTime exportedAt,
  String appVersion,
});

/// Turns a [ClassroomTransfer] into the text of a class file and back,
/// refusing a file that is no class file, is damaged, or comes from a
/// newer app.
final class ClassroomFileCodec {
  /// Creates the codec.
  const ClassroomFileCodec();

  /// The text of the file of [content]; a top-level-friendly signature,
  /// so it runs in a background isolate with `compute`.
  static String encodeContent(ClassroomFileContent content) {
    return const ClassroomFileCodec().encode(
      content.transfer,
      exportedAt: content.exportedAt,
      appVersion: content.appVersion,
    );
  }

  /// The transfer of [text]; runs in a background isolate with
  /// `compute`.
  static ClassroomTransfer decodeText(String text) {
    return const ClassroomFileCodec().decode(text);
  }

  /// The text of the file of [transfer], written at [exportedAt] by the
  /// app [appVersion].
  String encode(
    ClassroomTransfer transfer, {
    required DateTime exportedAt,
    required String appVersion,
  }) {
    return jsonEncode(
      ClassroomFileModel(
        format: ClassroomFileModel.formatName,
        version: ClassroomFileModel.currentVersion,
        exportedAt: exportedAt.toUtc().toIso8601String(),
        appVersion: appVersion,
        classroom: ClassroomLocalModel.fromEntity(transfer.classroom),
        pupils: transfer.pupils.map(ClassPupilFileModel.fromEntity).toList(),
        assignments: transfer.assignments
            .map(AssignmentLocalModel.fromEntity)
            .toList(),
        sessions: <ClassSessionFileModel>[
          for (final PracticeSession session in transfer.sessions)
            ClassSessionFileModel.fromEntity(session, exportedAt: exportedAt),
        ],
        assessments: transfer.assessments
            .map(ClassAssessmentLocalModel.fromEntity)
            .toList(),
        assessmentResults: transfer.assessmentResults
            .map(AssessmentResultFileModel.fromEntity)
            .toList(),
      ).toJson(),
    );
  }

  /// Reads [text], the content of a file.
  ///
  /// Throws an [InvalidFileException] when it is no class file or is
  /// damaged, and an [UnsupportedVersionException] when its version is
  /// newer than [ClassroomFileModel.currentVersion].
  ClassroomTransfer decode(String text) {
    final Map<String, Object?> json = _objectOf(text);
    final Object? version = json['version'];
    if (json['format'] != ClassroomFileModel.formatName ||
        version is! int ||
        version < 1) {
      throw const InvalidFileException(message: 'Not a class file.');
    }
    if (version > ClassroomFileModel.currentVersion) {
      throw UnsupportedVersionException(message: 'Class file v$version.');
    }
    try {
      return _transferOf(ClassroomFileModel.fromJson(json));
    } on TypeError catch (error) {
      throw InvalidFileException(message: error.toString());
    } on ArgumentError catch (error) {
      // A date out of range or an unknown value.
      throw InvalidFileException(message: error.toString());
    } on FormatException catch (error) {
      throw InvalidFileException(message: error.message);
    }
  }

  static ClassroomTransfer _transferOf(ClassroomFileModel file) {
    final String classroomId = file.classroom.id;
    return ClassroomTransfer(
      classroom: file.classroom.toEntity(),
      pupils: <PupilEntity>[
        for (final ClassPupilFileModel pupil in file.pupils)
          pupil.toEntity(classroomId),
      ],
      assignments: <AssignmentEntity>[
        for (final AssignmentLocalModel row in file.assignments) row.toEntity(),
      ],
      sessions: <PracticeSession>[
        for (final ClassSessionFileModel entry in file.sessions)
          entry.toEntity(),
      ],
      assessments: <ClassAssessment>[
        for (final ClassAssessmentLocalModel row in file.assessments)
          row.toEntity(),
      ],
      assessmentResults: <AssessmentResult>[
        for (final AssessmentResultFileModel entry in file.assessmentResults)
          entry.toEntity(),
      ],
    );
  }

  static Map<String, Object?> _objectOf(String text) {
    try {
      final Object? json = jsonDecode(text);
      if (json is Map<String, Object?>) return json;
    } on FormatException catch (error) {
      throw InvalidFileException(message: error.message);
    }
    throw const InvalidFileException(message: 'Not a JSON object.');
  }
}
