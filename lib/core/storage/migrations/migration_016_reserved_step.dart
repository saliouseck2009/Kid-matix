import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 16: a released empty step; never replace it.
///
/// Version 16 was reserved for the word problems (lot F30), which needed
/// no migration; the assessments of F31 took version 17. Devices already
/// at version 16 or later have run this empty step: a change here would
/// never reach them, so a schema change always takes a new version.
final class Migration016ReservedStep implements DatabaseMigration {
  /// Creates the migration.
  const Migration016ReservedStep();

  @override
  int get version => 16;

  @override
  Future<void> migrate(Database database) async {}
}
