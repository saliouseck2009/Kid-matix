import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 6: how a boss fight ended.
///
/// `boss_outcome` is `defeated` or `fled` for a boss fight, `NULL` for any
/// other quiz and for the sessions saved before. The SQL is written out in
/// full: a released migration never changes.
final class Migration006AddQuizSessionBossOutcome implements DatabaseMigration {
  /// Creates the migration.
  const Migration006AddQuizSessionBossOutcome();

  @override
  int get version => 6;

  @override
  Future<void> migrate(Database database) async {
    await database.execute(
      'ALTER TABLE quiz_session ADD COLUMN boss_outcome TEXT',
    );
  }
}
