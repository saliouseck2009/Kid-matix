import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Placeholder of schema version 14, reserved for the dated placement
/// results of lot F27, developed at the same time as the class mode.
///
/// It changes nothing; it only keeps the versions contiguous so that
/// migration 15 can run. Drop this file and use the migration of F27 when
/// both lots meet on `main`: no database outside development ever ran it.
final class Migration014ReservedForPlacement implements DatabaseMigration {
  /// Creates the migration.
  const Migration014ReservedForPlacement();

  @override
  int get version => 14;

  @override
  Future<void> migrate(Database database) async {}
}
