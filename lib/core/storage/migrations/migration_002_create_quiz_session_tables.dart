import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 2: the journal of the quiz sessions and their answers.
///
/// Rows are written once and never updated. Deleting a profile deletes its
/// sessions, and deleting a session deletes its answers. The SQL is written
/// out in full: a released migration never changes.
final class Migration002CreateQuizSessionTables implements DatabaseMigration {
  /// Creates the migration.
  const Migration002CreateQuizSessionTables();

  static const List<String> _statements = <String>[
    '''
    CREATE TABLE quiz_session (
      id TEXT PRIMARY KEY NOT NULL,
      profile_id TEXT NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
      domain_id TEXT NOT NULL,
      mode TEXT NOT NULL,
      status TEXT NOT NULL,
      started_at INTEGER NOT NULL,
      duration_ms INTEGER NOT NULL,
      question_count INTEGER NOT NULL,
      correct_count INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER
    )
    ''',
    '''
    CREATE INDEX quiz_session_profile_started
    ON quiz_session (profile_id, started_at)
    ''',
    '''
    CREATE TABLE quiz_answer (
      session_id TEXT NOT NULL
        REFERENCES quiz_session (id) ON DELETE CASCADE,
      position INTEGER NOT NULL,
      item_key TEXT NOT NULL,
      question_type_id TEXT NOT NULL,
      is_correct INTEGER NOT NULL,
      is_timed_out INTEGER NOT NULL,
      is_retry INTEGER NOT NULL,
      answer_time_ms INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      PRIMARY KEY (session_id, position)
    )
    ''',
  ];

  @override
  int get version => 2;

  @override
  Future<void> migrate(Database database) async {
    final Batch batch = database.batch();
    for (final String statement in _statements) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }
}
