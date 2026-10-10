import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 4: what each quiz session was played for.
///
/// `source_key` is an opaque key of the feature that started the quiz,
/// such as a stage of the learning path; `NULL` for the sessions saved
/// before. The SQL is written out in full: a released migration never
/// changes.
final class Migration004AddQuizSessionSource implements DatabaseMigration {
  /// Creates the migration.
  const Migration004AddQuizSessionSource();

  @override
  int get version => 4;

  @override
  Future<void> migrate(Database database) async {
    await database.execute(
      'ALTER TABLE quiz_session ADD COLUMN source_key TEXT',
    );
  }
}
