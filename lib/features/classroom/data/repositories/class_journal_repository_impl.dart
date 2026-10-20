import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/classroom/data/datasources/class_journal_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_tables.dart';
import 'package:kid_matix/features/classroom/data/models/class_answer_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_session_local_model.dart';
import 'package:kid_matix/features/classroom/data/repositories/classroom_storage_guard.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/repositories/class_journal_repository.dart';

/// [ClassJournalRepository] over the local database.
final class ClassJournalRepositoryImpl implements ClassJournalRepository {
  /// Creates the repository.
  const ClassJournalRepositoryImpl({
    required this._journal,
    required this._clock,
    required this._changeBus,
  });

  final ClassJournalLocalDataSource _journal;
  final Clock _clock;
  final TableChangeBus _changeBus;

  /// The rows of [session], written at [updatedAt].
  static ClassSessionRows rowsOf(
    PracticeSession session, {
    required DateTime updatedAt,
  }) {
    return (
      session: ClassSessionLocalModel.fromEntity(
        session,
        updatedAt: updatedAt,
      ),
      answers: <ClassAnswerLocalModel>[
        for (final PracticeAnswer answer in session.answers)
          ClassAnswerLocalModel.fromEntity(
            answer,
            sessionId: session.id,
            updatedAt: updatedAt,
          ),
      ],
    );
  }

  @override
  Future<DataState<List<PracticeSession>>> getSessions({
    required String classroomId,
  }) {
    return guardClassroomStorage(() async {
      final List<ClassSessionRows> rows = await _journal.getSessions(
        classroomId: classroomId,
      );
      return rows
          .map((ClassSessionRows row) => row.session.toEntity(row.answers))
          .toList();
    });
  }

  @override
  Future<DataState<int>> addSessions({
    required List<PracticeSession> sessions,
  }) {
    return guardClassroomStorage(() async {
      final DateTime now = _clock.now();
      final int insertedCount = await _journal.insertSessions(
        sessions: <ClassSessionRows>[
          for (final PracticeSession session in sessions)
            rowsOf(session, updatedAt: now),
        ],
      );
      if (insertedCount > 0) {
        _changeBus.notifyChanged(table: ClassroomTables.session);
      }
      return insertedCount;
    });
  }

  @override
  Stream<void> watchChanges() {
    return _changeBus.watchTable(table: ClassroomTables.session);
  }
}
