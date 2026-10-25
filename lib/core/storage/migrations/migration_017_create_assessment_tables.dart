import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 17: the dated assessments of a class (lot F31).
///
/// - `class_assessment`: an assessment a teacher opened for a class, with
///   the label of its period (« Début d'année ») and its dates; pupils
///   take it until it is closed.
/// - `assessment_result`: one row per pupil who finished it, dated, with
///   the words of the word check asked and understood.
/// - `assessment_level`: the level the placement test of that pupil found
///   in each domain (`level` NULL when the test did not reach the domain,
///   not the same as 0), out of `skill_count`.
/// - `assessment_word`: each word of the word check, understood or not.
///
/// These rows belong to the class, not to the child's game: the progress
/// reset of a pupil keeps them (no reset hook), deleting the pupil or the
/// class deletes them. The SQL is written out in full: a released
/// migration never changes.
final class Migration017CreateAssessmentTables implements DatabaseMigration {
  /// Creates the migration.
  const Migration017CreateAssessmentTables();

  static const List<String> _statements = <String>[
    '''
    CREATE TABLE class_assessment (
      id TEXT PRIMARY KEY NOT NULL,
      classroom_id TEXT NOT NULL
        REFERENCES classroom (id) ON DELETE CASCADE,
      period_label TEXT NOT NULL,
      opened_at INTEGER NOT NULL,
      closed_at INTEGER,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER
    )
    ''',
    '''
    CREATE INDEX class_assessment_classroom
    ON class_assessment (classroom_id)
    ''',
    '''
    CREATE TABLE assessment_result (
      assessment_id TEXT NOT NULL
        REFERENCES class_assessment (id) ON DELETE CASCADE,
      profile_id TEXT NOT NULL
        REFERENCES profile (id) ON DELETE CASCADE,
      taken_at INTEGER NOT NULL,
      word_count INTEGER NOT NULL,
      understood_word_count INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      PRIMARY KEY (assessment_id, profile_id)
    )
    ''',
    '''
    CREATE TABLE assessment_level (
      assessment_id TEXT NOT NULL,
      profile_id TEXT NOT NULL,
      domain_id TEXT NOT NULL,
      level INTEGER,
      skill_count INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      PRIMARY KEY (assessment_id, profile_id, domain_id),
      FOREIGN KEY (assessment_id, profile_id)
        REFERENCES assessment_result (assessment_id, profile_id)
        ON DELETE CASCADE
    )
    ''',
    '''
    CREATE TABLE assessment_word (
      assessment_id TEXT NOT NULL,
      profile_id TEXT NOT NULL,
      item_key TEXT NOT NULL,
      is_understood INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      PRIMARY KEY (assessment_id, profile_id, item_key),
      FOREIGN KEY (assessment_id, profile_id)
        REFERENCES assessment_result (assessment_id, profile_id)
        ON DELETE CASCADE
    )
    ''',
  ];

  @override
  int get version => 17;

  @override
  Future<void> migrate(Database database) async {
    final Batch batch = database.batch();
    for (final String statement in _statements) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }
}
