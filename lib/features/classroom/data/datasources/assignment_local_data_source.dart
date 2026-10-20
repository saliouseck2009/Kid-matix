import 'package:kid_matix/features/classroom/data/models/assignment_local_model.dart';

/// The assignments stored in the local SQLite database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository
/// turns them into typed failures.
abstract interface class AssignmentLocalDataSource {
  /// Returns the live assignments of [classroomId], oldest first.
  Future<List<AssignmentLocalModel>> getAssignments({
    required String classroomId,
  });

  /// Inserts [assignment], or replaces the stored row with the same id
  /// when [assignment] is newer; returns whether a row was written.
  Future<bool> upsertAssignment({required AssignmentLocalModel assignment});
}
