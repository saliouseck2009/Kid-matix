import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_tables.dart';
import 'package:kid_matix/features/classroom/data/models/classroom_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [ClassroomLocalDataSource] over the app database.
final class ClassroomLocalDataSourceImpl implements ClassroomLocalDataSource {
  /// Creates the data source over [database].
  const ClassroomLocalDataSourceImpl({required this._database});

  static const String _isLiveWithId = 'id = ? AND ${ClassroomTables.isLive}';

  final AppDatabase _database;

  @override
  Future<List<ClassroomLocalModel>> getClassrooms() async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ClassroomTables.classroom,
      where: ClassroomTables.isLive,
      orderBy: 'created_at, id',
    );
    return rows.map(ClassroomLocalModel.fromJson).toList();
  }

  @override
  Future<ClassroomLocalModel?> getClassroom({
    required String classroomId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ClassroomTables.classroom,
      where: _isLiveWithId,
      whereArgs: <Object>[classroomId],
    );
    return rows.isEmpty ? null : ClassroomLocalModel.fromJson(rows.single);
  }

  @override
  Future<void> insertClassroom({
    required ClassroomLocalModel classroom,
  }) async {
    final Database database = await _database.database;
    await database.insert(ClassroomTables.classroom, classroom.toJson());
  }

  @override
  Future<int> updateClassroom({required ClassroomLocalModel classroom}) async {
    final Database database = await _database.database;
    return database.update(
      ClassroomTables.classroom,
      classroom.toJson(),
      where: _isLiveWithId,
      whereArgs: <Object>[classroom.id],
    );
  }

  @override
  Future<int> deleteClassroom({required String classroomId}) async {
    final Database database = await _database.database;
    return database.delete(
      ClassroomTables.classroom,
      where: 'id = ?',
      whereArgs: <Object>[classroomId],
    );
  }
}
