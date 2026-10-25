import 'package:meta/meta.dart';

/// A unit the teacher gives a class to work on: « Le devoir de la
/// classe ».
@immutable
final class AssignmentEntity {
  /// Creates the assignment [id].
  const AssignmentEntity({
    required this.id,
    required this.classroomId,
    required this.domainId,
    required this.unitKey,
    required this.createdAt,
    required this.updatedAt,
    this.dueAt,
  });

  /// Unique identifier, a UUID.
  final String id;

  /// Class it is given to.
  final String classroomId;

  /// Learning domain of the unit, such as `addition`.
  final String domainId;

  /// Unit to work on, such as `addsub:sums-20`.
  final String unitKey;

  /// When the teacher gave it; the latest one is the class's current
  /// assignment.
  final DateTime createdAt;

  /// Last change; on a merge, the latest change wins.
  final DateTime updatedAt;

  /// Day it is due, or `null` when it has none.
  final DateTime? dueAt;

  /// Returns a copy with the given fields replaced.
  AssignmentEntity copyWith({
    String? id,
    String? classroomId,
    String? domainId,
    String? unitKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueAt,
  }) {
    return AssignmentEntity(
      id: id ?? this.id,
      classroomId: classroomId ?? this.classroomId,
      domainId: domainId ?? this.domainId,
      unitKey: unitKey ?? this.unitKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueAt: dueAt ?? this.dueAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AssignmentEntity &&
            other.id == id &&
            other.classroomId == classroomId &&
            other.domainId == domainId &&
            other.unitKey == unitKey &&
            other.createdAt == createdAt &&
            other.updatedAt == updatedAt &&
            other.dueAt == dueAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    classroomId,
    domainId,
    unitKey,
    createdAt,
    updatedAt,
    dueAt,
  );

  @override
  String toString() => 'AssignmentEntity($id, $unitKey)';
}
