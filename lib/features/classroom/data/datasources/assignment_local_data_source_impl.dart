import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/classroom/data/datasources/assignment_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_tables.dart';
import 'package:kid_matix/features/classroom/data/models/assignment_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [AssignmentLocalDataSource] over the app database.
final class AssignmentLocalDataSourceImpl implements AssignmentLocalDataSource {
  /// Creates the data source over [database].
  const AssignmentLocalDataSourceImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<List<AssignmentLocalModel>> getAssignments({
    required String classroomId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ClassroomTables.assignment,
      where: 'classroom_id = ? AND ${ClassroomTables.isLive}',
      whereArgs: <Object>[classroomId],
      orderBy: 'created_at, id',
    );
    return rows.map(AssignmentLocalModel.fromJson).toList();
  }

  @override
  Future<bool> upsertAssignment({
    required AssignmentLocalModel assignment,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> kept = await database.query(
      ClassroomTables.assignment,
      columns: <String>['updated_at'],
      where: 'id = ?',
      whereArgs: <Object>[assignment.id],
    );
    if (kept.isEmpty) {
      await database.insert(ClassroomTables.assignment, assignment.toJson());
      return true;
    }
    if ((kept.single['updated_at']! as int) >= assignment.updatedAt) {
      return false;
    }
    await database.update(
      ClassroomTables.assignment,
      assignment.toJson(),
      where: 'id = ?',
      whereArgs: <Object>[assignment.id],
    );
    return true;
  }
}
