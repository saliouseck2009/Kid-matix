import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 10: the XP earned outside a quiz, such as in a duel.
///
/// One row per award: its player, the game that earned it, the XP and
/// when. `session_reward` keeps the XP of the quizzes only, since its rows
/// point to a quiz session. Deleting a profile deletes its rows. The SQL
/// is written out in full: a released migration never changes.
final class Migration010CreateXpAwardTable implements DatabaseMigration {
  /// Creates the migration.
  const Migration010CreateXpAwardTable();

  @override
  int get version => 10;

  @override
  Future<void> migrate(Database database) async {
    await database.execute('''
      CREATE TABLE xp_award (
        id TEXT PRIMARY KEY NOT NULL,
        profile_id TEXT NOT NULL
          REFERENCES profile (id) ON DELETE CASCADE,
        source_key TEXT NOT NULL,
        xp_earned INTEGER NOT NULL,
        earned_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');
    await database.execute(
      'CREATE INDEX xp_award_profile_earned '
      'ON xp_award (profile_id, earned_at)',
    );
  }
}
