import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';

/// The results of the pupils of the classes: the sessions they played,
/// with their answers.
///
/// Filled as the pupils play on this device, and by the class files
/// received from other tablets.
abstract interface class ClassJournalRepository {
  /// Returns the sessions of the pupils of [classroomId], with their
  /// answers, oldest first. With [afterSequence], only those written on
  /// this device (played or merged here) after that local sequence, plus
  /// those started from [startedFrom]: an overlap the merge ignores.
  Future<DataState<List<PracticeSession>>> getSessions({
    required String classroomId,
    int? afterSequence,
    DateTime? startedFrom,
  });

  /// Returns the local sequence of the last session of [classroomId]
  /// written on this device: the clock plays no part in it.
  Future<DataState<int>> getLatestSequence({required String classroomId});

  /// Adds [sessions] with their answers, all or nothing; a session whose
  /// identifier is already kept is left as it is, so a file received
  /// twice adds nothing. Resolves to how many sessions were added.
  Future<DataState<int>> addSessions({
    required List<PracticeSession> sessions,
  });

  /// Emits an event after each change to the results.
  Stream<void> watchChanges();
}
