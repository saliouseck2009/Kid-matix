import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 12: the "Lire les questions à voix haute" setting of each
/// player (lot F23).
///
/// `is_read_aloud_enabled` is 1 when every new question is read aloud by
/// itself. Off (0) for the players who already exist, and for new ones
/// unless they turn it on when they are created. The SQL is written out in
/// full: a released migration never changes.
final class Migration012AddReadAloudSetting implements DatabaseMigration {
  /// Creates the migration.
  const Migration012AddReadAloudSetting();

  @override
  int get version => 12;

  @override
  Future<void> migrate(Database database) async {
    await database.execute('''
      ALTER TABLE profile_settings
      ADD COLUMN is_read_aloud_enabled INTEGER NOT NULL DEFAULT 0
    ''');
  }
}
