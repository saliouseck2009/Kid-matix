import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/mascot/data/datasources/mascot_tables.dart';
import 'package:kid_matix/features/mascot/domain/services/mascot_rules.dart';
import 'package:sqflite/sqflite.dart';

/// Takes off the accessories of a player's mascot, which go back with the
/// crowns and badges, and forgets the stages celebrated; the name stays.
final class MascotResetHook implements ProgressResetHook {
  /// Creates the hook.
  const MascotResetHook();

  @override
  Future<List<String>> reset(
    Transaction transaction, {
    required String profileId,
  }) async {
    await transaction.update(
      MascotTables.mascot,
      <String, Object?>{
        'worn_accessories': '',
        'celebrated_stage': MascotRules.firstStage,
      },
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
    );
    return const <String>[MascotTables.mascot];
  }
}
