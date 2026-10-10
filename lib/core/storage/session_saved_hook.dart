import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

/// A quiz session as it is being saved, given to the [SessionSavedHook]s.
@immutable
final class SavedQuizSession {
  /// Creates the session.
  const SavedQuizSession({
    required this.id,
    required this.profileId,
    required this.domainId,
    required this.isCompleted,
    required this.questionCount,
    required this.correctCount,
    required this.endedAt,
    this.sourceKey,
    this.bossOutcome,
  });

  /// Identifier of the session.
  final String id;

  /// Player.
  final String profileId;

  /// Learning domain.
  final String domainId;

  /// Whether the quiz was completed rather than abandoned.
  final bool isCompleted;

  /// Scored questions answered.
  final int questionCount;

  /// Right answers among them.
  final int correctCount;

  /// When the session ended.
  final DateTime endedAt;

  /// What the quiz was played for, or `null`.
  final String? sourceKey;

  /// How a boss fight ended, `defeated` or `fled`, or `null` for another
  /// quiz.
  final String? bossOutcome;
}

/// Writes what a feature keeps from a quiz session, inside the
/// transaction that saves the session: all or nothing.
///
/// The learning path stores the stars of a stage this way; rewards will
/// follow. Implemented in the data layer of the owning feature.
abstract interface class SessionSavedHook {
  /// Writes with [transaction] what [session] changes, and returns the
  /// tables written, to notify once the transaction is committed.
  Future<List<String>> onSessionSaved({
    required Transaction transaction,
    required SavedQuizSession session,
  });
}

/// The [SessionSavedHook]s of the app, added by each feature at startup.
final class SessionSavedHooks {
  final List<SessionSavedHook> _hooks = <SessionSavedHook>[];

  /// Every hook, in the order they were added.
  List<SessionSavedHook> get hooks =>
      List<SessionSavedHook>.unmodifiable(_hooks);

  /// Adds [hook].
  void add(SessionSavedHook hook) => _hooks.add(hook);
}
