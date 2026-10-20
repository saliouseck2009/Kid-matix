import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 15: the class mode (lot F29).
///
/// - `classroom`: a class of the device, with the weekly goal of its
///   class challenge (right answers).
/// - `profile.classroom_id`: a pupil is an ordinary player attached to a
///   class; `NULL` for the free players. Nicknames are unique among the
///   free players and inside each class, so two classes can both hold
///   « 01 » or « Awa ».
/// - `assignment`: the units a teacher gives to a class.
/// - `class_session` and `class_answer`: the results of the pupils, kept
///   by the class mode apart from the quiz journal, so that they can be
///   carried to the teacher's tablet by file and merged without
///   duplicates (the identifiers are the quiz session ids).
///
/// The SQL is written out in full: a released migration never changes.
final class Migration015CreateClassroomTables implements DatabaseMigration {
  /// Creates the migration.
  const Migration015CreateClassroomTables();

  static const List<String> _statements = <String>[
    '''
    CREATE TABLE classroom (
      id TEXT PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      weekly_goal INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER
    )
    ''',
    '''
    ALTER TABLE profile
    ADD COLUMN classroom_id TEXT REFERENCES classroom (id)
    ''',
    'DROP INDEX profile_normalized_nickname_unique',
    '''
    CREATE UNIQUE INDEX profile_free_nickname_unique
    ON profile (normalized_nickname)
    WHERE deleted_at IS NULL AND classroom_id IS NULL
    ''',
    '''
    CREATE UNIQUE INDEX profile_pupil_nickname_unique
    ON profile (classroom_id, normalized_nickname)
    WHERE deleted_at IS NULL AND classroom_id IS NOT NULL
    ''',
    'CREATE INDEX profile_classroom ON profile (classroom_id)',
    '''
    CREATE TABLE assignment (
      id TEXT PRIMARY KEY NOT NULL,
      classroom_id TEXT NOT NULL
        REFERENCES classroom (id) ON DELETE CASCADE,
      domain_id TEXT NOT NULL,
      unit_key TEXT NOT NULL,
      due_at INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER
    )
    ''',
    'CREATE INDEX assignment_classroom ON assignment (classroom_id)',
    '''
    CREATE TABLE class_session (
      id TEXT PRIMARY KEY NOT NULL,
      profile_id TEXT NOT NULL
        REFERENCES profile (id) ON DELETE CASCADE,
      classroom_id TEXT NOT NULL
        REFERENCES classroom (id) ON DELETE CASCADE,
      domain_id TEXT NOT NULL,
      started_at INTEGER NOT NULL,
      duration_ms INTEGER NOT NULL,
      question_count INTEGER NOT NULL,
      correct_count INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER
    )
    ''',
    '''
    CREATE INDEX class_session_classroom_started
    ON class_session (classroom_id, started_at)
    ''',
    '''
    CREATE TABLE class_answer (
      session_id TEXT NOT NULL
        REFERENCES class_session (id) ON DELETE CASCADE,
      position INTEGER NOT NULL,
      item_key TEXT NOT NULL,
      is_correct INTEGER NOT NULL,
      is_retry INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      PRIMARY KEY (session_id, position)
    )
    ''',
  ];

  @override
  int get version => 15;

  @override
  Future<void> migrate(Database database) async {
    final Batch batch = database.batch();
    for (final String statement in _statements) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }
}
