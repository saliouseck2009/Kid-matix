import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 9: the records of the challenges.
///
/// One row per player and mode, such as `timeAttack`: the best score, the
/// session that set it, when, and the record it beat. Deleting a profile
/// deletes its rows. The SQL is written out in full: a released migration
/// never changes.
final class Migration009CreateRecordTable implements DatabaseMigration {
  /// Creates the migration.
  const Migration009CreateRecordTable();

  @override
  int get version => 9;

  @override
  Future<void> migrate(Database database) async {
    await database.execute('''
      CREATE TABLE record (
        profile_id TEXT NOT NULL
          REFERENCES profile (id) ON DELETE CASCADE,
        mode TEXT NOT NULL,
        best_score INTEGER NOT NULL,
        session_id TEXT NOT NULL,
        achieved_at INTEGER NOT NULL,
        previous_best INTEGER,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        PRIMARY KEY (profile_id, mode)
      )
    ''');
    await database.execute(
      'CREATE INDEX record_session_idx ON record (session_id)',
    );
  }
}
