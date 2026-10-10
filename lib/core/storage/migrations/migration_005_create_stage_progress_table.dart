import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 5: the best result of each player on each stage of the
/// learning path.
///
/// One row per player, domain, unit and stage, written in the
/// transaction that saves the quiz session. Deleting a profile deletes
/// its rows. The SQL is written out in full: a released migration never
/// changes.
final class Migration005CreateStageProgressTable implements DatabaseMigration {
  /// Creates the migration.
  const Migration005CreateStageProgressTable();

  @override
  int get version => 5;

  @override
  Future<void> migrate(Database database) async {
    await database.execute('''
      CREATE TABLE stage_progress (
        profile_id TEXT NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
        domain_id TEXT NOT NULL,
        unit_key TEXT NOT NULL,
        stage TEXT NOT NULL,
        best_stars INTEGER NOT NULL,
        best_score INTEGER NOT NULL,
        completed_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        PRIMARY KEY (profile_id, domain_id, unit_key, stage)
      )
    ''');
  }
}
