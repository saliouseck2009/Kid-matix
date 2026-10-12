import 'dart:async';

import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/setting/domain/usecases/record_finished_session_use_case.dart';
import 'package:sqflite/sqflite.dart';

/// Leaves out today's reminder once a player of the phone finishes a
/// quiz session: an abandoned quiz changes nothing.
///
/// It writes nothing in the database. The day is kept in the device
/// preferences and the notifications scheduled again without waiting, so
/// the transaction that saves the session is not held by the plugin.
final class ReminderSessionHook implements SessionSavedHook {
  /// Creates the hook; [recordFinishedSession] gives the use case when a
  /// session ends, so the preferences and the plugin are only reached
  /// then, never while the app starts.
  const ReminderSessionHook({required this._recordFinishedSession});

  final RecordFinishedSessionUseCase Function() _recordFinishedSession;

  @override
  Future<SessionWrite> prepare({required SavedQuizSession session}) async {
    return (Transaction transaction) async {
      if (session.isCompleted) {
        unawaited(_recordFinishedSession()(params: session.endedAt));
      }
      return const <String>[];
    };
  }
}
