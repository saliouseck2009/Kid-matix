import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 14: the dated results of the placement test (lot F27).
///
/// One row per player, test and domain: `taken_at` dates the test (every
/// row of one test shares it), `level` counts the skills of the domain the
/// child has out of `skill_count` (NULL when the test stopped before any
/// skill of the domain: not reached is not the same as none), and
/// `unit_count` the units the test opened. `start_unit_key` is filled on the
/// row of the domain the test recommends starting with, and only there. A
/// later test adds rows; none is rewritten, so a start and an end of
/// period can be compared. Deleting a profile deletes its rows. The SQL is
/// written out in full: a released migration never changes.
final class Migration014CreatePlacementResultTable
    implements DatabaseMigration {
  /// Creates the migration.
  const Migration014CreatePlacementResultTable();

  @override
  int get version => 14;

  @override
  Future<void> migrate(Database database) async {
    await database.execute('''
      CREATE TABLE placement_result (
        profile_id TEXT NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
        taken_at INTEGER NOT NULL,
        domain_id TEXT NOT NULL,
        level INTEGER,
        skill_count INTEGER NOT NULL,
        unit_count INTEGER NOT NULL,
        start_unit_key TEXT,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        PRIMARY KEY (profile_id, taken_at, domain_id)
      )
    ''');
  }
}
