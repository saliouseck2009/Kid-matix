import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/learning_path/data/datasources/learning_path_tables.dart';
import 'package:sqflite/sqflite.dart';

/// Erases the dated placement results of a player with the rest of their
/// progress.
final class PlacementResultResetHook implements ProgressResetHook {
  /// Creates the hook.
  const PlacementResultResetHook();

  @override
  Future<List<String>> reset(
    Transaction transaction, {
    required String profileId,
  }) async {
    await transaction.delete(
      LearningPathTables.placementResult,
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
    );
    return const <String>[LearningPathTables.placementResult];
  }
}
