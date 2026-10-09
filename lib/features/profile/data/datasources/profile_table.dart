/// Names of the `profile` table and its columns.
abstract final class ProfileTable {
  /// Table name.
  static const String name = 'profile';

  /// Primary key column.
  static const String id = 'id';

  /// Uniqueness key: the nickname without case or accents.
  static const String normalizedNickname = 'normalized_nickname';

  /// Creation date column, in milliseconds since epoch.
  static const String createdAt = 'created_at';
}
