import 'package:kid_matix/features/classroom/data/models/class_answer_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_session_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// A session row with its answer rows.
typedef ClassSessionRows = ({
  ClassSessionLocalModel session,
  List<ClassAnswerLocalModel> answers,
});

/// The class results stored in the local SQLite database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository
/// turns them into typed failures.
abstract interface class ClassJournalLocalDataSource {
  /// Returns the live sessions of [classroomId] with their answers,
  /// oldest first; only those written on this device after
  /// [writtenAfterMs] (milliseconds since epoch) when it is given.
  Future<List<ClassSessionRows>> getSessions({
    required String classroomId,
    int? writtenAfterMs,
  });

  /// Inserts [sessions] in one transaction; returns how many were new.
  Future<int> insertSessions({required List<ClassSessionRows> sessions});

  /// Inserts [rows] with [executor] unless its session is already kept;
  /// returns whether it was new. Used inside the transaction that saves
  /// a quiz session.
  Future<bool> insertSessionWith(
    DatabaseExecutor executor,
    ClassSessionRows rows,
  );
}
