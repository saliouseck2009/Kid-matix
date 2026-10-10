import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_tables.dart';
import 'package:sqflite/sqflite.dart';

/// Erases the quiz journal of a player: their sessions, and with them
/// their answers and the XP earned (deleted in cascade).
final class QuizResetHook implements ProgressResetHook {
  /// Creates the hook.
  const QuizResetHook();

  @override
  Future<List<String>> reset(
    Transaction transaction, {
    required String profileId,
  }) async {
    await transaction.delete(
      QuizTables.session,
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
    );
    return const <String>[QuizTables.session, QuizTables.answer];
  }
}
