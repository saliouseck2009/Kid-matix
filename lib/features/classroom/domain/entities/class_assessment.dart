import 'package:meta/meta.dart';

/// An assessment a teacher opened for a class, at the start or the end of
/// a period: each pupil takes the placement test and the word check
/// once, until it is closed.
///
/// Its identifier travels with the class files, so the pupils of every
/// tablet take the same assessment.
@immutable
final class ClassAssessment {
  /// Creates the assessment [id] of [classroomId].
  const ClassAssessment({
    required this.id,
    required this.classroomId,
    required this.periodLabel,
    required this.openedAt,
    required this.updatedAt,
    this.closedAt,
  });

  /// Unique identifier, a UUID.
  final String id;

  /// Class assessed.
  final String classroomId;

  /// Name the teacher gave the period, such as « Début d'année »; the
  /// reports group the assessments of one period by it.
  final String periodLabel;

  /// When the teacher opened it.
  final DateTime openedAt;

  /// When the teacher closed it, or `null` while pupils can take it.
  final DateTime? closedAt;

  /// Last change; on a merge, the latest change wins.
  final DateTime updatedAt;

  /// Whether pupils can still take it.
  bool get isOpen => closedAt == null;

  /// Returns a copy with the given fields replaced.
  ClassAssessment copyWith({
    String? id,
    String? classroomId,
    String? periodLabel,
    DateTime? openedAt,
    DateTime? closedAt,
    DateTime? updatedAt,
  }) {
    return ClassAssessment(
      id: id ?? this.id,
      classroomId: classroomId ?? this.classroomId,
      periodLabel: periodLabel ?? this.periodLabel,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClassAssessment &&
            other.id == id &&
            other.classroomId == classroomId &&
            other.periodLabel == periodLabel &&
            other.openedAt == openedAt &&
            other.closedAt == closedAt &&
            other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, classroomId, periodLabel, openedAt, closedAt, updatedAt);

  @override
  String toString() => 'ClassAssessment($id, $periodLabel)';
}
