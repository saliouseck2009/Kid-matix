import 'package:meta/meta.dart';

/// A class of the device, created by its teacher.
///
/// Its identifier travels with the class files, so the same class is
/// recognized on every tablet it is copied to.
@immutable
final class ClassroomEntity {
  /// Creates the class [id].
  const ClassroomEntity({
    required this.id,
    required this.name,
    required this.weeklyGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier, a UUID.
  final String id;

  /// Name the teacher gave, such as « CE1 B ».
  final String name;

  /// Right answers the whole class aims at each week, for its class
  /// challenge.
  final int weeklyGoal;

  /// When the class was created.
  final DateTime createdAt;

  /// Last change of the name or of the goal; on a merge, the latest
  /// change wins.
  final DateTime updatedAt;

  /// Returns a copy with the given fields replaced.
  ClassroomEntity copyWith({
    String? id,
    String? name,
    int? weeklyGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassroomEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClassroomEntity &&
            other.id == id &&
            other.name == name &&
            other.weeklyGoal == weeklyGoal &&
            other.createdAt == createdAt &&
            other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, name, weeklyGoal, createdAt, updatedAt);

  @override
  String toString() => 'ClassroomEntity($id, $name)';
}
