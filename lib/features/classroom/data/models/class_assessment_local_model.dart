import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';

part 'class_assessment_local_model.g.dart';

/// Row of the `class_assessment` table, also written as is in the class
/// files.
@JsonSerializable(fieldRename: FieldRename.snake)
final class ClassAssessmentLocalModel {
  /// Creates a row with every column given.
  const ClassAssessmentLocalModel({
    required this.id,
    required this.classroomId,
    required this.periodLabel,
    required this.openedAt,
    required this.updatedAt,
    this.closedAt,
    this.deletedAt,
  });

  /// Builds the row of [assessment].
  factory ClassAssessmentLocalModel.fromEntity(ClassAssessment assessment) {
    return ClassAssessmentLocalModel(
      id: assessment.id,
      classroomId: assessment.classroomId,
      periodLabel: assessment.periodLabel,
      openedAt: assessment.openedAt.millisecondsSinceEpoch,
      closedAt: assessment.closedAt?.millisecondsSinceEpoch,
      updatedAt: assessment.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite` or a class file.
  factory ClassAssessmentLocalModel.fromJson(Map<String, Object?> json) =>
      _$ClassAssessmentLocalModelFromJson(json);

  /// Primary key, a UUID.
  final String id;

  /// Class assessed.
  final String classroomId;

  /// Name of the period.
  final String periodLabel;

  /// When it was opened, in milliseconds since epoch.
  final int openedAt;

  /// When it was closed, in milliseconds since epoch, or `null`.
  final int? closedAt;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$ClassAssessmentLocalModelToJson(this);

  /// Returns the assessment of this row.
  ClassAssessment toEntity() {
    final int? closedAt = this.closedAt;
    return ClassAssessment(
      id: id,
      classroomId: classroomId,
      periodLabel: periodLabel,
      openedAt: DateTime.fromMillisecondsSinceEpoch(openedAt),
      closedAt: closedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(closedAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}
