import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_tables.dart';
import 'package:kid_matix/features/classroom/data/models/classroom_local_model.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [ClassroomRepository] over the local database.
final class ClassroomRepositoryImpl implements ClassroomRepository {
  /// Creates the repository.
  const ClassroomRepositoryImpl({
    required this._classrooms,
    required this._changeBus,
  });

  static const String _logName = 'classroom';

  final ClassroomLocalDataSource _classrooms;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<List<ClassroomEntity>>> getClassrooms() {
    return _guard(() async {
      final List<ClassroomLocalModel> rows = await _classrooms.getClassrooms();
      return rows.map((ClassroomLocalModel row) => row.toEntity()).toList();
    });
  }

  @override
  Future<DataState<ClassroomEntity>> getClassroom({
    required String classroomId,
  }) {
    return _guard(() async {
      final ClassroomLocalModel? row = await _classrooms.getClassroom(
        classroomId: classroomId,
      );
      if (row == null) throw _notFound(classroomId);
      return row.toEntity();
    });
  }

  @override
  Future<DataState<void>> createClassroom({
    required ClassroomEntity classroom,
  }) {
    return _guard(() async {
      await _classrooms.insertClassroom(
        classroom: ClassroomLocalModel.fromEntity(classroom),
      );
      _notifyChanged();
    });
  }

  @override
  Future<DataState<void>> updateClassroom({
    required ClassroomEntity classroom,
  }) {
    return _guard(() async {
      final int changedRows = await _classrooms.updateClassroom(
        classroom: ClassroomLocalModel.fromEntity(classroom),
      );
      if (changedRows == 0) throw _notFound(classroom.id);
      _notifyChanged();
    });
  }

  @override
  Future<DataState<void>> mergeClassroom({
    required ClassroomEntity classroom,
  }) {
    return _guard(() async {
      final bool isWritten = await _classrooms.upsertClassroom(
        classroom: ClassroomLocalModel.fromEntity(classroom),
      );
      if (isWritten) _notifyChanged();
    });
  }

  @override
  Stream<void> watchChanges() {
    return _changeBus.watchTable(table: ClassroomTables.classroom);
  }

  void _notifyChanged() {
    _changeBus.notifyChanged(table: ClassroomTables.classroom);
  }

  static NotFoundException _notFound(String classroomId) {
    return NotFoundException(message: 'No class $classroomId.');
  }

  /// Runs [action] and turns its outcome or its failure into a [DataState].
  Future<DataState<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return DataSuccess<T>(await action());
    } on AppException catch (exception) {
      return DataFailed<T>(exception);
    } on DatabaseException catch (error, stackTrace) {
      log(
        'Database failure',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<T>(CacheException(message: error.toString()));
    }
  }
}
