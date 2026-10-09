/// Names of the `profile_settings` table and its columns.
abstract final class ProfileSettingsTable {
  /// Table name.
  static const String name = 'profile_settings';

  /// Key column, the identifier of the owning profile.
  static const String profileId = 'profile_id';
}
