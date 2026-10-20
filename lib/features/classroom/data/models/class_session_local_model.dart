import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/classroom/data/models/class_answer_local_model.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';

part 'class_session_local_model.g.dart';

/// Row of the `class_session` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class ClassSessionLocalModel {
  /// Creates a row with every column given.
  const ClassSessionLocalModel({
    required this.id,
    required this.profileId,
    required this.classroomId,
    required this.domainId,
    required this.startedAt,
    required this.durationMs,
    required this.questionCount,
    required this.correctCount,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Builds the row of [session], written at [updatedAt].
  factory ClassSessionLocalModel.fromEntity(
    PracticeSession session, {
    required DateTime updatedAt,
  }) {
    return ClassSessionLocalModel(
      id: session.id,
      profileId: session.pupilId,
      classroomId: session.classroomId,
      domainId: session.domainId,
      startedAt: session.startedAt.millisecondsSinceEpoch,
      durationMs: session.duration.inMilliseconds,
      questionCount: session.questionCount,
      correctCount: session.correctCount,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite` or a class file.
  factory ClassSessionLocalModel.fromJson(Map<String, Object?> json) =>
      _$ClassSessionLocalModelFromJson(json);

  /// Primary key: the identifier of the quiz session.
  final String id;

  /// Pupil who played.
  final String profileId;

  /// Class of the pupil.
  final String classroomId;

  /// Learning domain.
  final String domainId;

  /// Start, in milliseconds since epoch.
  final int startedAt;

  /// Time played, in milliseconds.
  final int durationMs;

  /// Scored questions answered.
  final int questionCount;

  /// Right answers among them.
  final int correctCount;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$ClassSessionLocalModelToJson(this);

  /// Returns the session of this row with its [answers].
  PracticeSession toEntity(List<ClassAnswerLocalModel> answers) {
    return PracticeSession(
      id: id,
      pupilId: profileId,
      classroomId: classroomId,
      domainId: domainId,
      startedAt: DateTime.fromMillisecondsSinceEpoch(startedAt),
      duration: Duration(milliseconds: durationMs),
      questionCount: questionCount,
      correctCount: correctCount,
      answers: answers
          .map((ClassAnswerLocalModel answer) => answer.toEntity())
          .toList(),
    );
  }
}
