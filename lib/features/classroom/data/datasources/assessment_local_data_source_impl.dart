import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/classroom/data/datasources/assessment_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_tables.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_level_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_result_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_result_rows.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_word_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_assessment_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [AssessmentLocalDataSource] over the app database.
final class AssessmentLocalDataSourceImpl implements AssessmentLocalDataSource {
  /// Creates the data source over [database].
  const AssessmentLocalDataSourceImpl({required this._database});

  static const String _ofClass =
      'assessment_id IN (SELECT id FROM ${ClassroomTables.assessment} '
      'WHERE classroom_id = ? AND deleted_at IS NULL) AND deleted_at IS NULL';

  final AppDatabase _database;

  @override
  Future<List<ClassAssessmentLocalModel>> getAssessments({
    required String classroomId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ClassroomTables.assessment,
      where: 'classroom_id = ? AND ${ClassroomTables.isLive}',
      whereArgs: <Object>[classroomId],
      orderBy: 'opened_at, id',
    );
    return rows.map(ClassAssessmentLocalModel.fromJson).toList();
  }

  @override
  Future<ClassAssessmentLocalModel?> getAssessment({
    required String assessmentId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ClassroomTables.assessment,
      where: 'id = ? AND ${ClassroomTables.isLive}',
      whereArgs: <Object>[assessmentId],
    );
    return rows.isEmpty ? null : ClassAssessmentLocalModel.fromJson(rows.first);
  }

  @override
  Future<bool> upsertAssessment({
    required ClassAssessmentLocalModel assessment,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> kept = await database.query(
      ClassroomTables.assessment,
      columns: <String>['updated_at'],
      where: 'id = ?',
      whereArgs: <Object>[assessment.id],
    );
    if (kept.isEmpty) {
      await database.insert(ClassroomTables.assessment, assessment.toJson());
      return true;
    }
    if ((kept.single['updated_at']! as int) >= assessment.updatedAt) {
      return false;
    }
    await database.update(
      ClassroomTables.assessment,
      assessment.toJson(),
      where: 'id = ?',
      whereArgs: <Object>[assessment.id],
    );
    return true;
  }

  @override
  Future<List<AssessmentResultRows>> getResults({
    required String classroomId,
  }) async {
    final Database database = await _database.database;
    final List<Object> arguments = <Object>[classroomId];
    final List<Map<String, Object?>> results = await database.query(
      ClassroomTables.assessmentResult,
      where: _ofClass,
      whereArgs: arguments,
      orderBy: 'taken_at, assessment_id, profile_id',
    );
    final List<Map<String, Object?>> levels = await database.query(
      ClassroomTables.assessmentLevel,
      where: _ofClass,
      whereArgs: arguments,
      // The order of the placement test, kept from the insertion.
      orderBy: 'rowid',
    );
    final List<Map<String, Object?>> words = await database.query(
      ClassroomTables.assessmentWord,
      where: _ofClass,
      whereArgs: arguments,
      orderBy: 'rowid',
    );
    return _rowsOf(results, levels, words);
  }

  @override
  Future<int> insertResults({
    required List<AssessmentResultRows> results,
  }) async {
    final Database database = await _database.database;
    return database.transaction((Transaction transaction) async {
      int insertedCount = 0;
      for (final AssessmentResultRows rows in results) {
        if (await insertResultWith(transaction, rows)) insertedCount++;
      }
      return insertedCount;
    });
  }

  @override
  Future<bool> insertResultWith(
    DatabaseExecutor executor,
    AssessmentResultRows rows,
  ) async {
    final List<Map<String, Object?>> kept = await executor.query(
      ClassroomTables.assessmentResult,
      columns: <String>['taken_at'],
      where: 'assessment_id = ? AND profile_id = ?',
      whereArgs: <Object>[rows.result.assessmentId, rows.result.profileId],
    );
    if (kept.isNotEmpty) return false;
    await executor.insert(
      ClassroomTables.assessmentResult,
      rows.result.toJson(),
    );
    final Batch batch = executor.batch();
    for (final AssessmentLevelLocalModel level in rows.levels) {
      batch.insert(ClassroomTables.assessmentLevel, level.toJson());
    }
    for (final AssessmentWordLocalModel word in rows.words) {
      batch.insert(
        ClassroomTables.assessmentWord,
        word.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
    return true;
  }

  static List<AssessmentResultRows> _rowsOf(
    List<Map<String, Object?>> results,
    List<Map<String, Object?>> levels,
    List<Map<String, Object?>> words,
  ) {
    final Map<String, List<AssessmentLevelLocalModel>> levelsOf =
        <String, List<AssessmentLevelLocalModel>>{};
    for (final Map<String, Object?> row in levels) {
      final AssessmentLevelLocalModel level =
          AssessmentLevelLocalModel.fromJson(row);
      levelsOf
          .putIfAbsent(
            _keyOf(level.assessmentId, level.profileId),
            () => <AssessmentLevelLocalModel>[],
          )
          .add(level);
    }
    final Map<String, List<AssessmentWordLocalModel>> wordsOf =
        <String, List<AssessmentWordLocalModel>>{};
    for (final Map<String, Object?> row in words) {
      final AssessmentWordLocalModel word = AssessmentWordLocalModel.fromJson(
        row,
      );
      wordsOf
          .putIfAbsent(
            _keyOf(word.assessmentId, word.profileId),
            () => <AssessmentWordLocalModel>[],
          )
          .add(word);
    }
    return <AssessmentResultRows>[
      for (final Map<String, Object?> row in results)
        () {
          final AssessmentResultLocalModel result =
              AssessmentResultLocalModel.fromJson(row);
          final String key = _keyOf(result.assessmentId, result.profileId);
          return (
            result: result,
            levels: levelsOf[key] ?? const <AssessmentLevelLocalModel>[],
            words: wordsOf[key] ?? const <AssessmentWordLocalModel>[],
          );
        }(),
    ];
  }

  static String _keyOf(String assessmentId, String profileId) =>
      '$assessmentId/$profileId';
}
