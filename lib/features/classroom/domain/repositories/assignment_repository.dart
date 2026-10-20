import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';

/// The assignments given to the classes.
abstract interface class AssignmentRepository {
  /// Returns the assignments of [classroomId], oldest first.
  Future<DataState<List<AssignmentEntity>>> getAssignments({
    required String classroomId,
  });

  /// Stores [assignment], or replaces the stored one with the same
  /// identifier when [assignment] changed later.
  Future<DataState<void>> saveAssignment({
    required AssignmentEntity assignment,
  });

  /// Emits an event after each change to the assignments.
  Stream<void> watchChanges();
}
