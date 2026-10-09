/// Columns carried by every table of the local database.
///
/// They record when a row last changed and whether it was soft-deleted, which
/// a future synchronisation with a server needs.
abstract final class CommonColumns {
  /// Milliseconds since epoch of the last change to the row.
  static const String updatedAt = 'updated_at';

  /// Milliseconds since epoch of the soft deletion, or `NULL` when live.
  static const String deletedAt = 'deleted_at';

  /// SQL fragment to append to the column list of a `CREATE TABLE`.
  static const String definition =
      '$updatedAt INTEGER NOT NULL, $deletedAt INTEGER';
}
