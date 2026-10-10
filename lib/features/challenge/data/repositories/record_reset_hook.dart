import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/challenge/data/datasources/challenge_tables.dart';
import 'package:sqflite/sqflite.dart';

/// Erases the records of a player.
final class RecordResetHook implements ProgressResetHook {
  /// Creates the hook.
  const RecordResetHook();

  @override
  Future<List<String>> reset(
    Transaction transaction, {
    required String profileId,
  }) async {
    await transaction.delete(
      ChallengeTables.record,
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
    );
    return const <String>[ChallengeTables.record];
  }
}
