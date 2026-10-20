import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/classroom/data/datasources/assignment_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_tables.dart';
import 'package:kid_matix/features/classroom/data/models/assignment_local_model.dart';
import 'package:kid_matix/features/classroom/data/repositories/classroom_storage_guard.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assignment_repository.dart';

/// [AssignmentRepository] over the local database.
final class AssignmentRepositoryImpl implements AssignmentRepository {
  /// Creates the repository.
  const AssignmentRepositoryImpl({
    required this._assignments,
    required this._changeBus,
  });

  final AssignmentLocalDataSource _assignments;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<List<AssignmentEntity>>> getAssignments({
    required String classroomId,
  }) {
    return guardClassroomStorage(() async {
      final List<AssignmentLocalModel> rows = await _assignments.getAssignments(
        classroomId: classroomId,
      );
      return rows.map((AssignmentLocalModel row) => row.toEntity()).toList();
    });
  }

  @override
  Future<DataState<void>> saveAssignment({
    required AssignmentEntity assignment,
  }) {
    return guardClassroomStorage(() async {
      final bool isWritten = await _assignments.upsertAssignment(
        assignment: AssignmentLocalModel.fromEntity(assignment),
      );
      if (isWritten) {
        _changeBus.notifyChanged(table: ClassroomTables.assignment);
      }
    });
  }

  @override
  Stream<void> watchChanges() {
    return _changeBus.watchTable(table: ClassroomTables.assignment);
  }
}
