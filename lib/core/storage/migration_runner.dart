import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:kid_matix/core/storage/version_change.dart';
import 'package:sqflite/sqflite.dart';

/// Applies the pending [DatabaseMigration]s in version order.
final class MigrationRunner {
  /// Creates a runner over [migrations], whose versions must be 1, 2, 3...
  MigrationRunner({required List<DatabaseMigration> migrations})
    : _migrations = List<DatabaseMigration>.unmodifiable(
        List<DatabaseMigration>.of(migrations)..sort(_compareByVersion),
      ) {
    assert(_hasContiguousVersions(), 'Migration versions must be 1, 2, 3...');
  }

  final List<DatabaseMigration> _migrations;

  /// Highest schema version, or 0 when there is no migration yet.
  int get latestVersion => _migrations.isEmpty ? 0 : _migrations.last.version;

  /// Runs on [database] every migration covered by [change].
  Future<void> run({
    required Database database,
    required VersionChange change,
  }) async {
    final Iterable<DatabaseMigration> pendingMigrations = _migrations.where(
      (DatabaseMigration migration) => change.includes(migration.version),
    );
    for (final DatabaseMigration migration in pendingMigrations) {
      await migration.migrate(database);
    }
  }

  static int _compareByVersion(DatabaseMigration a, DatabaseMigration b) {
    return a.version.compareTo(b.version);
  }

  bool _hasContiguousVersions() {
    for (int index = 0; index < _migrations.length; index++) {
      if (_migrations[index].version != index + 1) return false;
    }
    return true;
  }
}
