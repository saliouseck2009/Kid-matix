import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 1: the players and their settings.
///
/// The SQL is written out in full on purpose: a released migration is a
/// frozen snapshot and must not change when a column constant of the data
/// layer is renamed later.
final class Migration001CreateProfileTables implements DatabaseMigration {
  /// Creates the migration.
  const Migration001CreateProfileTables();

  static const List<String> _statements = <String>[
    '''
    CREATE TABLE profile (
      id TEXT PRIMARY KEY NOT NULL,
      remote_account_id TEXT,
      nickname TEXT NOT NULL,
      normalized_nickname TEXT NOT NULL,
      avatar TEXT NOT NULL,
      color TEXT NOT NULL,
      total_xp INTEGER NOT NULL DEFAULT 0,
      level INTEGER NOT NULL DEFAULT 1,
      created_at INTEGER NOT NULL,
      last_played_at INTEGER,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER
    )
    ''',
    '''
    CREATE UNIQUE INDEX profile_normalized_nickname_unique
    ON profile (normalized_nickname)
    WHERE deleted_at IS NULL
    ''',
    '''
    CREATE TABLE profile_settings (
      profile_id TEXT PRIMARY KEY NOT NULL
        REFERENCES profile (id) ON DELETE CASCADE,
      timer_mode TEXT NOT NULL,
      daily_goal_xp INTEGER NOT NULL,
      is_sound_enabled INTEGER NOT NULL,
      is_vibration_enabled INTEGER NOT NULL,
      is_reduced_motion_enabled INTEGER NOT NULL,
      is_everything_unlocked INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER
    )
    ''',
  ];

  @override
  int get version => 1;

  @override
  Future<void> migrate(Database database) async {
    final Batch batch = database.batch();
    for (final String statement in _statements) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }
}
