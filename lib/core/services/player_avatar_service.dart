import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/data_state.dart';

/// The avatar a player wears, as the shop sees and changes it.
///
/// Implemented by the profile feature, which owns the players.
abstract interface class PlayerAvatarService {
  /// Returns the nickname, avatar and color of [profileId].
  Future<DataState<PlayerIdentity>> readPlayer({required String profileId});

  /// Puts the avatar named [avatarKey], such as `fox`, on [profileId].
  Future<DataState<void>> wearAvatar({
    required String profileId,
    required String avatarKey,
  });

  /// Emits an event each time a player may have changed.
  Stream<void> watchChanges();
}
