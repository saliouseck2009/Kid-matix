import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_challenge.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:meta/meta.dart';

/// What a pupil sees of their class on the home: « Le devoir de la
/// classe » with their own progress, and the gauge of the class
/// challenge.
@immutable
final class PupilClassView {
  /// Creates the view of [classroom].
  const PupilClassView({
    required this.classroom,
    required this.challenge,
    this.assignment,
    this.assignmentProgress,
  });

  /// The pupil's class.
  final ClassroomEntity classroom;

  /// The class's current assignment, or `null`.
  final AssignmentEntity? assignment;

  /// Share of the items of the assignment the pupil acquired, from 0 to
  /// 1, or `null` without assignment.
  final double? assignmentProgress;

  /// The class challenge of the week.
  final ClassChallenge challenge;

  /// Returns a copy with the given fields replaced.
  PupilClassView copyWith({
    ClassroomEntity? classroom,
    AssignmentEntity? assignment,
    double? assignmentProgress,
    ClassChallenge? challenge,
  }) {
    return PupilClassView(
      classroom: classroom ?? this.classroom,
      assignment: assignment ?? this.assignment,
      assignmentProgress: assignmentProgress ?? this.assignmentProgress,
      challenge: challenge ?? this.challenge,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PupilClassView &&
            other.classroom == classroom &&
            other.assignment == assignment &&
            other.assignmentProgress == assignmentProgress &&
            other.challenge == challenge;
  }

  @override
  int get hashCode =>
      Object.hash(classroom, assignment, assignmentProgress, challenge);
}
