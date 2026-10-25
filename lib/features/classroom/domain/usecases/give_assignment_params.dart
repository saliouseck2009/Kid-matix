import 'package:meta/meta.dart';

/// A unit the teacher gives a class.
@immutable
final class GiveAssignmentParams {
  /// Creates the parameters.
  const GiveAssignmentParams({
    required this.classroomId,
    required this.domainId,
    required this.unitKey,
    this.dueInDays,
  });

  /// Class that receives it.
  final String classroomId;

  /// Learning domain of the unit.
  final String domainId;

  /// Unit to work on.
  final String unitKey;

  /// Days from today to the day it is due, or `null` for no date.
  final int? dueInDays;
}
