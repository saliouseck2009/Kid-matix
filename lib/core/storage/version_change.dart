/// A move of the database schema from one version to a later one.
final class VersionChange {
  /// Creates a change from version [from] (exclusive) to [to] (inclusive).
  const VersionChange({required this.from, required this.to})
    : assert(from >= 0, 'A schema version cannot be negative.'),
      assert(to >= from, 'A schema never moves backwards.');

  /// Version the database is currently at; 0 for a brand-new database.
  final int from;

  /// Version the database must reach.
  final int to;

  /// Whether the migration numbered [version] must run for this change.
  bool includes(int version) => version > from && version <= to;
}
