import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 3: the mastery of each item, per player.
///
/// One row per player, domain and item, created at the first presentation
/// of the item and updated after each answer. Deleting a profile deletes
/// its rows. The SQL is written out in full: a released migration never
/// changes.
final class Migration003CreateItemProgressTable implements DatabaseMigration {
  /// Creates the migration.
  const Migration003CreateItemProgressTable();

  static const List<String> _statements = <String>[
    '''
    CREATE TABLE item_progress (
      profile_id TEXT NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
      domain_id TEXT NOT NULL,
      item_key TEXT NOT NULL,
      presentation_count INTEGER NOT NULL,
      correct_count INTEGER NOT NULL,
      last_answer_times_ms TEXT NOT NULL,
      box INTEGER NOT NULL,
      next_review_at INTEGER,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      PRIMARY KEY (profile_id, domain_id, item_key)
    )
    ''',
    '''
    CREATE INDEX item_progress_review
    ON item_progress (profile_id, domain_id, next_review_at)
    ''',
  ];

  @override
  int get version => 3;

  @override
  Future<void> migrate(Database database) async {
    final Batch batch = database.batch();
    for (final String statement in _statements) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }
}
