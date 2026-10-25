import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 16: a step without change.
///
/// Version 16 is reserved for the word problems (lot F30), built at the
/// same time as the assessments of F31 (version 17), and the versions
/// must follow each other. When F30 needs a migration, its own replaces
/// this file before the merge; when it needs none, this empty step is
/// kept, so that version 17 stays as it is.
final class Migration016ReservedStep implements DatabaseMigration {
  /// Creates the migration.
  const Migration016ReservedStep();

  @override
  int get version => 16;

  @override
  Future<void> migrate(Database database) async {}
}
