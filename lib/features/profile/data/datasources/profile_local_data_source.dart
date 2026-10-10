import 'package:kid_matix/features/profile/data/models/profile_local_model.dart';
import 'package:kid_matix/features/profile/data/models/profile_settings_local_model.dart';

/// Profiles stored in the local SQLite database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository turns
/// them into typed failures.
abstract interface class ProfileLocalDataSource {
  /// Returns every live profile, oldest first.
  Future<List<ProfileLocalModel>> getProfiles();

  /// Returns the live profile [profileId], or `null` when there is none.
  Future<ProfileLocalModel?> getProfile({required String profileId});

  /// Returns the settings of [profileId], or `null` when there are none.
  Future<ProfileSettingsLocalModel?> getSettings({required String profileId});

  /// Replaces the settings of their profile; returns the rows changed.
  Future<int> updateSettings({required ProfileSettingsLocalModel settings});

  /// Returns how many live profiles exist.
  Future<int> countProfiles();

  /// Whether a live profile other than [excludedProfileId] has the
  /// [normalizedNickname].
  Future<bool> hasNormalizedNickname({
    required String normalizedNickname,
    String? excludedProfileId,
  });

  /// Inserts [profile] and its [settings] in one transaction.
  Future<void> insertProfile({
    required ProfileLocalModel profile,
    required ProfileSettingsLocalModel settings,
  });

  /// Overwrites the live row of [profile]; returns how many rows changed.
  Future<int> updateProfile({required ProfileLocalModel profile});

  /// Deletes the profile [profileId] and, in cascade, every row that
  /// belongs to it; returns how many profiles were deleted.
  Future<int> deleteProfile({required String profileId});
}
