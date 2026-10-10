import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 8: the choices the child makes for the mascot.
///
/// One row per player, created at the first choice: the name of the
/// mascot, the accessories worn (names separated by commas) and the
/// highest stage already celebrated. Deleting a profile deletes its row.
/// The SQL is written out in full: a released migration never changes.
final class Migration008CreateMascotTable implements DatabaseMigration {
  /// Creates the migration.
  const Migration008CreateMascotTable();

  @override
  int get version => 8;

  @override
  Future<void> migrate(Database database) async {
    await database.execute('''
      CREATE TABLE mascot (
        profile_id TEXT PRIMARY KEY NOT NULL
          REFERENCES profile (id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        worn_accessories TEXT NOT NULL,
        celebrated_stage INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');
  }
}
