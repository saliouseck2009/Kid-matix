import 'package:sqflite/sqflite.dart';

/// One incremental step of the local database schema.
///
/// Each schema version has exactly one migration. A released migration is
/// never edited: a later change ships as a new migration.
abstract interface class DatabaseMigration {
  /// Schema version reached once this migration has run; starts at 1.
  int get version;

  /// Applies the schema change to [database].
  Future<void> migrate(Database database);
}
