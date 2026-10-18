import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_avatar_service.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// [PlayerAvatarService] over the stored profiles.
final class PlayerAvatarServiceImpl implements PlayerAvatarService {
  /// Creates the service over [repository].
  const PlayerAvatarServiceImpl({required this._repository});

  final ProfileRepository _repository;

  @override
  Future<DataState<PlayerIdentity>> readPlayer({
    required String profileId,
  }) async {
    return switch (await _repository.getProfile(profileId: profileId)) {
      DataSuccess<ProfileEntity>(:final data) => DataSuccess<PlayerIdentity>(
        PlayerIdentity(
          id: data.id,
          nickname: data.nickname,
          avatarKey: data.avatar.name,
          colorKey: data.color.name,
        ),
      ),
      DataFailed<ProfileEntity>(:final exception) => DataFailed<PlayerIdentity>(
        exception,
      ),
    };
  }

  @override
  Future<DataState<void>> wearAvatar({
    required String profileId,
    required String avatarKey,
  }) async {
    final ProfileAvatar? avatar = ProfileAvatar.values.asNameMap()[avatarKey];
    if (avatar == null) {
      return DataFailed<void>(
        ValidationException(message: 'Unknown avatar $avatarKey.'),
      );
    }
    final DataState<ProfileEntity> read = await _repository.getProfile(
      profileId: profileId,
    );
    if (read case DataFailed<ProfileEntity>(:final exception)) {
      return DataFailed<void>(exception);
    }
    final ProfileEntity profile = (read as DataSuccess<ProfileEntity>).data;
    return switch (await _repository.updateProfile(
      profile: profile.copyWith(avatar: avatar),
    )) {
      DataSuccess<ProfileEntity>() => const DataSuccess<void>(null),
      DataFailed<ProfileEntity>(:final exception) => DataFailed<void>(
        exception,
      ),
    };
  }

  @override
  Stream<void> watchChanges() => _repository.watchProfileChanges();
}
