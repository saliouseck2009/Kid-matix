import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 7: the rewards of each player.
///
/// `session_reward` keeps the XP of each completed quiz, `streak` the
/// daily streak, `badge_unlock` the badges with the session that unlocked
/// them, and `reward_stats` the counters some badges need. Deleting a
/// profile deletes its rows. The SQL is written out in full: a released
/// migration never changes.
final class Migration007CreateRewardTables implements DatabaseMigration {
  /// Creates the migration.
  const Migration007CreateRewardTables();

  static const List<String> _statements = <String>[
    '''
    CREATE TABLE session_reward (
      session_id TEXT PRIMARY KEY NOT NULL
        REFERENCES quiz_session (id) ON DELETE CASCADE,
      profile_id TEXT NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
      xp_earned INTEGER NOT NULL,
      xp_version INTEGER NOT NULL,
      earned_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER
    )
    ''',
    '''
    CREATE INDEX session_reward_profile_earned
    ON session_reward (profile_id, earned_at)
    ''',
    '''
    CREATE TABLE streak (
      profile_id TEXT PRIMARY KEY NOT NULL
        REFERENCES profile (id) ON DELETE CASCADE,
      current_streak INTEGER NOT NULL,
      best_streak INTEGER NOT NULL,
      last_played_day INTEGER,
      joker_used_week INTEGER,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER
    )
    ''',
    '''
    CREATE TABLE badge_unlock (
      profile_id TEXT NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
      badge_key TEXT NOT NULL,
      unlocked_at INTEGER NOT NULL,
      session_id TEXT,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      PRIMARY KEY (profile_id, badge_key)
    )
    ''',
    '''
    CREATE TABLE reward_stats (
      profile_id TEXT PRIMARY KEY NOT NULL
        REFERENCES profile (id) ON DELETE CASCADE,
      lightning_answers INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER
    )
    ''',
  ];

  @override
  int get version => 7;

  @override
  Future<void> migrate(Database database) async {
    final Batch batch = database.batch();
    for (final String statement in _statements) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }
}
