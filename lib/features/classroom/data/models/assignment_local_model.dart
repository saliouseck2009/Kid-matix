import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';

part 'assignment_local_model.g.dart';

/// Row of the `assignment` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class AssignmentLocalModel {
  /// Creates a row with every column given.
  const AssignmentLocalModel({
    required this.id,
    required this.classroomId,
    required this.domainId,
    required this.unitKey,
    required this.createdAt,
    required this.updatedAt,
    this.dueAt,
    this.deletedAt,
  });

  /// Builds the row of [assignment].
  factory AssignmentLocalModel.fromEntity(AssignmentEntity assignment) {
    return AssignmentLocalModel(
      id: assignment.id,
      classroomId: assignment.classroomId,
      domainId: assignment.domainId,
      unitKey: assignment.unitKey,
      dueAt: assignment.dueAt?.millisecondsSinceEpoch,
      createdAt: assignment.createdAt.millisecondsSinceEpoch,
      updatedAt: assignment.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite` or a class file.
  factory AssignmentLocalModel.fromJson(Map<String, Object?> json) =>
      _$AssignmentLocalModelFromJson(json);

  /// Primary key, a UUID.
  final String id;

  /// Class it is given to.
  final String classroomId;

  /// Learning domain of the unit.
  final String domainId;

  /// Unit to work on.
  final String unitKey;

  /// Day it is due, in milliseconds since epoch, or `null`.
  final int? dueAt;

  /// When it was given, in milliseconds since epoch.
  final int createdAt;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$AssignmentLocalModelToJson(this);

  /// Returns the assignment of this row.
  AssignmentEntity toEntity() {
    final int? dueAt = this.dueAt;
    return AssignmentEntity(
      id: id,
      classroomId: classroomId,
      domainId: domainId,
      unitKey: unitKey,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      dueAt: dueAt == null ? null : DateTime.fromMillisecondsSinceEpoch(dueAt),
    );
  }
}
