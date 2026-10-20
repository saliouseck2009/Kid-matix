import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:meta/meta.dart';

/// What a class file carries from one tablet to another, with no
/// network: the class, its pupils, its assignments and the results of
/// its pupils.
///
/// Merging it is idempotent: every part keeps the identifiers of the
/// tablet it was made on.
@immutable
final class ClassroomTransfer {
  /// Creates the transfer of [classroom].
  const ClassroomTransfer({
    required this.classroom,
    required this.pupils,
    required this.assignments,
    required this.sessions,
  });

  /// The class.
  final ClassroomEntity classroom;

  /// Its pupils, in the order of the class list.
  final List<PupilEntity> pupils;

  /// Its assignments, oldest first.
  final List<AssignmentEntity> assignments;

  /// The sessions its pupils played, with their answers.
  final List<PracticeSession> sessions;

  /// Returns a copy with the given fields replaced.
  ClassroomTransfer copyWith({
    ClassroomEntity? classroom,
    List<PupilEntity>? pupils,
    List<AssignmentEntity>? assignments,
    List<PracticeSession>? sessions,
  }) {
    return ClassroomTransfer(
      classroom: classroom ?? this.classroom,
      pupils: pupils ?? this.pupils,
      assignments: assignments ?? this.assignments,
      sessions: sessions ?? this.sessions,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClassroomTransfer &&
            other.classroom == classroom &&
            Object.hashAll(other.pupils) == Object.hashAll(pupils) &&
            Object.hashAll(other.assignments) == Object.hashAll(assignments) &&
            Object.hashAll(other.sessions) == Object.hashAll(sessions);
  }

  @override
  int get hashCode => Object.hash(
    classroom,
    Object.hashAll(pupils),
    Object.hashAll(assignments),
    Object.hashAll(sessions),
  );
}
