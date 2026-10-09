import 'package:kid_matix/core/storage/database_path_resolver.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/version_change.dart';
import 'package:sqflite/sqflite.dart';

/// Owns the single connection to the local SQLite database.
///
/// The schema evolves only through numbered migrations: the database is
/// never dropped and recreated, so no player data is lost on update.
final class AppDatabase {
  /// Creates the database wrapper; nothing is opened until [database] is read.
  AppDatabase({
    required DatabaseFactory databaseFactory,
    required DatabasePathResolver resolvePath,
    required MigrationRunner migrationRunner,
  }) : _databaseFactory = databaseFactory,
       _resolvePath = resolvePath,
       _migrationRunner = migrationRunner;

  /// Name of the database file inside the platform databases directory.
  static const String fileName = 'kid_matix.db';

  static const String _enableForeignKeysStatement = 'PRAGMA foreign_keys = ON';

  final DatabaseFactory _databaseFactory;
  final DatabasePathResolver _resolvePath;
  final MigrationRunner _migrationRunner;
  Future<Database>? _opening;

  /// The open connection; the first read opens and migrates the database.
  Future<Database> get database => _opening ??= _open();

  /// Closes the connection if it was opened.
  Future<void> close() async {
    final Future<Database>? opening = _opening;
    if (opening == null) return;
    _opening = null;
    final Database openedDatabase = await opening;
    await openedDatabase.close();
  }

  Future<Database> _open() async {
    assert(_migrationRunner.latestVersion > 0, 'No migration is registered.');
    final String path = await _resolvePath();
    return _databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _migrationRunner.latestVersion,
        onConfigure: _enableForeignKeys,
        onCreate: _create,
        onUpgrade: _upgrade,
      ),
    );
  }

  Future<void> _enableForeignKeys(Database database) {
    return database.execute(_enableForeignKeysStatement);
  }

  Future<void> _create(Database database, int version) {
    return _migrationRunner.run(
      database: database,
      change: VersionChange(from: 0, to: version),
    );
  }

  Future<void> _upgrade(Database database, int oldVersion, int newVersion) {
    return _migrationRunner.run(
      database: database,
      change: VersionChange(from: oldVersion, to: newVersion),
    );
  }
}
