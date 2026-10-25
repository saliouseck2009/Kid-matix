import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_challenge.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_dashboard.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/level_group.dart';
import 'package:meta/meta.dart';

/// Everything the page of a class shows the teacher: the class and its
/// pupils, its assignment, its dashboard, its level groups and its
/// challenge of the week.
@immutable
final class ClassOverview {
  /// Creates the overview of [roster].
  const ClassOverview({
    required this.roster,
    required this.dashboard,
    required this.challenge,
    required this.groups,
    this.assignment,
    this.groupsDomainId,
  });

  /// The class and its pupils.
  final ClassroomRoster roster;

  /// The current assignment, or `null` when none was given.
  final AssignmentEntity? assignment;

  /// Each pupil and the items the class is stuck on.
  final ClassDashboard dashboard;

  /// The class challenge of the week.
  final ClassChallenge challenge;

  /// Domain of the level groups: the one of the assignment, or the one
  /// the class practised most; `null` before anything happened.
  final String? groupsDomainId;

  /// The proposed level groups in [groupsDomainId].
  final List<LevelGroup> groups;

  /// Returns a copy with the given fields replaced.
  ClassOverview copyWith({
    ClassroomRoster? roster,
    AssignmentEntity? assignment,
    ClassDashboard? dashboard,
    ClassChallenge? challenge,
    String? groupsDomainId,
    List<LevelGroup>? groups,
  }) {
    return ClassOverview(
      roster: roster ?? this.roster,
      assignment: assignment ?? this.assignment,
      dashboard: dashboard ?? this.dashboard,
      challenge: challenge ?? this.challenge,
      groupsDomainId: groupsDomainId ?? this.groupsDomainId,
      groups: groups ?? this.groups,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClassOverview &&
            other.roster == roster &&
            other.assignment == assignment &&
            other.dashboard == dashboard &&
            other.challenge == challenge &&
            other.groupsDomainId == groupsDomainId &&
            Object.hashAll(other.groups) == Object.hashAll(groups);
  }

  @override
  int get hashCode => Object.hash(
    roster,
    assignment,
    dashboard,
    challenge,
    groupsDomainId,
    Object.hashAll(groups),
  );
}
