import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/mastery/data/datasources/mastery_tables.dart';
import 'package:sqflite/sqflite.dart';

/// Erases the progress of every item of a player.
final class MasteryResetHook implements ProgressResetHook {
  /// Creates the hook.
  const MasteryResetHook();

  @override
  Future<List<String>> reset(
    Transaction transaction, {
    required String profileId,
  }) async {
    await transaction.delete(
      MasteryTables.itemProgress,
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
    );
    return const <String>[MasteryTables.itemProgress];
  }
}
