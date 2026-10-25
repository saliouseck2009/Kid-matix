import 'package:kid_matix/core/quiz/quiz_mode.dart';
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
    required this.mode,
    required this.isCompleted,
    required this.questionCount,
    required this.correctCount,
    required this.endedAt,
    this.sourceKey,
    this.bossOutcome,
    this.lightningCount = 0,
    this.duration = Duration.zero,
    this.answers = const <SavedAnswer>[],
  });

  /// Identifier of the session.
  final String id;

  /// Player.
  final String profileId;

  /// Learning domain.
  final String domainId;

  /// How the quiz was started.
  final QuizMode mode;

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

  /// Lightning answers among the scored ones.
  final int lightningCount;

  /// Time played, from the first question to the end.
  final Duration duration;

  /// Every answer of the session, second chances included, in order.
  final List<SavedAnswer> answers;

  /// When the session started.
  DateTime get startedAt => endedAt.subtract(duration);
}

/// One answer of a [SavedQuizSession].
@immutable
final class SavedAnswer {
  /// Creates the answer at [position] about [itemKey].
  const SavedAnswer({
    required this.position,
    required this.itemKey,
    required this.isCorrect,
    this.isRetry = false,
  });

  /// Order of the answer in the session, from 1.
  final int position;

  /// Item asked, such as `mul:7x8`.
  final String itemKey;

  /// Whether the answer was right.
  final bool isCorrect;

  /// Whether it was a second chance, asked again after a mistake.
  final bool isRetry;
}

/// What a hook writes inside the transaction that saves a session; it
/// returns the tables written, to notify once the transaction is
/// committed.
typedef SessionWrite = Future<List<String>> Function(Transaction transaction);

/// Writes what a feature keeps from a quiz session, inside the
/// transaction that saves the session: all or nothing.
///
/// The learning path stores the stars of a stage this way, the rewards
/// the XP, the streak and the badges. Implemented in the data layer of
/// the owning feature.
abstract interface class SessionSavedHook {
  /// Reads, before the transaction opens, what the hook needs from other
  /// features, and returns the write to run inside it.
  ///
  /// Reading the database while the transaction is open would wait for it
  /// forever: every read of another feature happens here.
  Future<SessionWrite> prepare({required SavedQuizSession session});
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
