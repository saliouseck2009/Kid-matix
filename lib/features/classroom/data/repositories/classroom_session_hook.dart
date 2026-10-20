import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/classroom/data/datasources/class_journal_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_tables.dart';
import 'package:kid_matix/features/classroom/data/repositories/class_journal_repository_impl.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:sqflite/sqflite.dart';

/// Keeps in the class results each quiz session a pupil plays, in the
/// transaction that saves it; the sessions of the free players are left
/// out.
final class ClassroomSessionHook implements SessionSavedHook {
  /// Creates the hook; [roster] is read at the first session, so that
  /// registering the hook resolves nothing.
  const ClassroomSessionHook({
    required PupilRosterService Function() roster,
    required this._journal,
  }) : _readRoster = roster;

  final PupilRosterService Function() _readRoster;
  final ClassJournalLocalDataSource _journal;

  @override
  Future<SessionWrite> prepare({required SavedQuizSession session}) async {
    final DataState<String?> classroom = await _readRoster().readClassroomOf(
      profileId: session.profileId,
    );
    final String? classroomId = switch (classroom) {
      DataSuccess<String?>(:final data) => data,
      DataFailed<String?>() => null,
    };
    if (classroomId == null || session.answers.isEmpty) return _nothing;
    final ClassSessionRows rows = ClassJournalRepositoryImpl.rowsOf(
      practiceOf(session, classroomId),
      updatedAt: session.endedAt,
    );
    return (Transaction transaction) async {
      await _journal.insertSessionWith(transaction, rows);
      return const <String>[ClassroomTables.session];
    };
  }

  /// The class result of [session], played by a pupil of [classroomId].
  static PracticeSession practiceOf(
    SavedQuizSession session,
    String classroomId,
  ) {
    return PracticeSession(
      id: session.id,
      pupilId: session.profileId,
      classroomId: classroomId,
      domainId: session.domainId,
      startedAt: session.startedAt,
      duration: session.duration,
      questionCount: session.questionCount,
      correctCount: session.correctCount,
      answers: <PracticeAnswer>[
        for (final SavedAnswer answer in session.answers)
          PracticeAnswer(
            position: answer.position,
            itemKey: answer.itemKey,
            isCorrect: answer.isCorrect,
            isRetry: answer.isRetry,
          ),
      ],
    );
  }

  static Future<List<String>> _nothing(Transaction transaction) async {
    return const <String>[];
  }
}
