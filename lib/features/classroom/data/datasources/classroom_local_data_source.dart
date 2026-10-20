import 'package:kid_matix/features/classroom/data/models/classroom_local_model.dart';

/// The classes stored in the local SQLite database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository
/// turns them into typed failures.
abstract interface class ClassroomLocalDataSource {
  /// Returns every live class, oldest first.
  Future<List<ClassroomLocalModel>> getClassrooms();

  /// Returns the live class [classroomId], or `null` when there is none.
  Future<ClassroomLocalModel?> getClassroom({required String classroomId});

  /// Inserts [classroom].
  Future<void> insertClassroom({required ClassroomLocalModel classroom});

  /// Overwrites the live row of [classroom]; returns the rows changed.
  Future<int> updateClassroom({required ClassroomLocalModel classroom});
}
