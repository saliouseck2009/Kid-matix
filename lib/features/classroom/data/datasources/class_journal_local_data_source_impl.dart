import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/classroom/data/datasources/class_journal_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_tables.dart';
import 'package:kid_matix/features/classroom/data/models/class_answer_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_session_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [ClassJournalLocalDataSource] over the app database.
final class ClassJournalLocalDataSourceImpl
    implements ClassJournalLocalDataSource {
  /// Creates the data source over [database].
  const ClassJournalLocalDataSourceImpl({required this._database});

  static const String _answersOfClass =
      'SELECT a.* FROM ${ClassroomTables.answer} a '
      'JOIN ${ClassroomTables.session} s ON s.id = a.session_id '
      'WHERE s.classroom_id = ? AND s.deleted_at IS NULL '
      'AND a.deleted_at IS NULL ORDER BY a.session_id, a.position';

  final AppDatabase _database;

  @override
  Future<List<ClassSessionRows>> getSessions({
    required String classroomId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> sessions = await database.query(
      ClassroomTables.session,
      where: 'classroom_id = ? AND ${ClassroomTables.isLive}',
      whereArgs: <Object>[classroomId],
      orderBy: 'started_at, id',
    );
    final List<Map<String, Object?>> answers = await database.rawQuery(
      _answersOfClass,
      <Object>[classroomId],
    );
    final Map<String, List<ClassAnswerLocalModel>> bySession =
        <String, List<ClassAnswerLocalModel>>{};
    for (final Map<String, Object?> row in answers) {
      final ClassAnswerLocalModel answer = ClassAnswerLocalModel.fromJson(row);
      bySession
          .putIfAbsent(answer.sessionId, () => <ClassAnswerLocalModel>[])
          .add(answer);
    }
    return <ClassSessionRows>[
      for (final Map<String, Object?> row in sessions)
        _rowsOf(ClassSessionLocalModel.fromJson(row), bySession),
    ];
  }

  @override
  Future<int> insertSessions({
    required List<ClassSessionRows> sessions,
  }) async {
    final Database database = await _database.database;
    return database.transaction((Transaction transaction) async {
      int insertedCount = 0;
      for (final ClassSessionRows rows in sessions) {
        if (await insertSessionWith(transaction, rows)) insertedCount++;
      }
      return insertedCount;
    });
  }

  @override
  Future<bool> insertSessionWith(
    DatabaseExecutor executor,
    ClassSessionRows rows,
  ) async {
    final List<Map<String, Object?>> kept = await executor.query(
      ClassroomTables.session,
      columns: <String>['id'],
      where: 'id = ?',
      whereArgs: <Object>[rows.session.id],
    );
    if (kept.isNotEmpty) return false;
    await executor.insert(ClassroomTables.session, rows.session.toJson());
    final Batch batch = executor.batch();
    for (final ClassAnswerLocalModel answer in rows.answers) {
      batch.insert(
        ClassroomTables.answer,
        answer.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
    return true;
  }

  static ClassSessionRows _rowsOf(
    ClassSessionLocalModel session,
    Map<String, List<ClassAnswerLocalModel>> bySession,
  ) {
    return (
      session: session,
      answers: bySession[session.id] ?? const <ClassAnswerLocalModel>[],
    );
  }
}
