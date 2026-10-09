import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';

/// Access to the players stored on the device and to the active player.
///
/// Every method returns a [DataState]: failures arrive as a `DataFailed`
/// carrying a typed `AppException`, never as a thrown exception.
abstract interface class ProfileRepository {
  /// Returns every profile, oldest first.
  Future<DataState<List<ProfileEntity>>> getProfiles();

  /// Returns the profile identified by [profileId].
  ///
  /// Fails with a `NotFoundException` when there is none.
  Future<DataState<ProfileEntity>> getProfile({required String profileId});

  /// Returns how many profiles exist.
  Future<DataState<int>> countProfiles();

  /// Whether another profile already uses [nickname].
  ///
  /// Nicknames are compared ignoring case and accents. The profile
  /// [excludedProfileId], if given, is left out: a player renaming
  /// themselves does not clash with their own nickname.
  Future<DataState<bool>> isNicknameTaken({
    required String nickname,
    String? excludedProfileId,
  });

  /// Stores the new [profile] with default settings.
  ///
  /// Fails with a `ConflictException` when the nickname is already taken.
  Future<DataState<ProfileEntity>> createProfile({
    required ProfileEntity profile,
  });

  /// Saves the changes made to an existing [profile].
  ///
  /// Fails with a `ConflictException` when the new nickname is already
  /// taken, and with a `NotFoundException` when the profile does not exist.
  Future<DataState<ProfileEntity>> updateProfile({
    required ProfileEntity profile,
  });

  /// Deletes the profile [profileId] and every piece of data it owns.
  ///
  /// When it was the active player, no player is active afterwards.
  Future<DataState<void>> deleteProfile({required String profileId});

  /// Returns the identifier of the last active player, or `null` when no
  /// player has been chosen yet.
  Future<DataState<String?>> getActiveProfileId();

  /// Remembers [profileId] as the active player across app launches.
  Future<DataState<void>> setActiveProfileId({required String profileId});

  /// Emits an event after each change to the profiles or to the active
  /// player.
  Stream<void> watchProfileChanges();
}
