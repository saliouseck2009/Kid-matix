import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';

part 'classroom_local_model.g.dart';

/// Row of the `classroom` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class ClassroomLocalModel {
  /// Creates a row with every column given.
  const ClassroomLocalModel({
    required this.id,
    required this.name,
    required this.weeklyGoal,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Builds the row of [classroom].
  factory ClassroomLocalModel.fromEntity(ClassroomEntity classroom) {
    return ClassroomLocalModel(
      id: classroom.id,
      name: classroom.name,
      weeklyGoal: classroom.weeklyGoal,
      createdAt: classroom.createdAt.millisecondsSinceEpoch,
      updatedAt: classroom.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite` or a class file.
  factory ClassroomLocalModel.fromJson(Map<String, Object?> json) =>
      _$ClassroomLocalModelFromJson(json);

  /// Primary key, a UUID.
  final String id;

  /// Name of the class.
  final String name;

  /// Right answers aimed at each week.
  final int weeklyGoal;

  /// Creation date, in milliseconds since epoch.
  final int createdAt;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$ClassroomLocalModelToJson(this);

  /// Returns the class of this row.
  ClassroomEntity toEntity() {
    return ClassroomEntity(
      id: id,
      name: name,
      weeklyGoal: weeklyGoal,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}
