import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/learning_path/data/datasources/learning_path_tables.dart';
import 'package:sqflite/sqflite.dart';

/// Erases the stars and crowns of a player on the learning path.
final class StageProgressResetHook implements ProgressResetHook {
  /// Creates the hook.
  const StageProgressResetHook();

  @override
  Future<List<String>> reset(
    Transaction transaction, {
    required String profileId,
  }) async {
    await transaction.delete(
      LearningPathTables.stageProgress,
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
    );
    return const <String>[LearningPathTables.stageProgress];
  }
}
