import 'dart:convert';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/features/classroom/data/models/assignment_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_answer_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_pupil_file_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_session_file_model.dart';
import 'package:kid_matix/features/classroom/data/models/classroom_file_model.dart';
import 'package:kid_matix/features/classroom/data/models/classroom_local_model.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/data/models/class_session_local_model.dart';

/// Turns a [ClassroomTransfer] into the text of a class file and back,
/// refusing a file that is no class file, is damaged, or comes from a
/// newer app.
final class ClassroomFileCodec {
  /// Creates the codec.
  const ClassroomFileCodec();

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
            _sessionModelOf(session, exportedAt),
        ],
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
          entry.session.toEntity(entry.answers),
      ],
    );
  }

  static ClassSessionFileModel _sessionModelOf(
    PracticeSession session,
    DateTime exportedAt,
  ) {
    return ClassSessionFileModel(
      session: ClassSessionLocalModel.fromEntity(
        session,
        updatedAt: exportedAt,
      ),
      answers: <ClassAnswerLocalModel>[
        for (final PracticeAnswer answer in session.answers)
          ClassAnswerLocalModel.fromEntity(
            answer,
            sessionId: session.id,
            updatedAt: exportedAt,
          ),
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
