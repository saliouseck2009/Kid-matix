import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_directory_service.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';

/// [PlayerDirectoryService] over the stored profiles.
final class PlayerDirectoryServiceImpl implements PlayerDirectoryService {
  /// Creates the service.
  const PlayerDirectoryServiceImpl({required this._getProfiles});

  final GetProfilesUseCase _getProfiles;

  @override
  Future<DataState<List<PlayerIdentity>>> readPlayers() async {
    return switch (await _getProfiles()) {
      DataSuccess<List<ProfileEntity>>(:final data) =>
        DataSuccess<List<PlayerIdentity>>(<PlayerIdentity>[
          // The pupils of the classes play neither the duel nor the
          // leaderboard of the phone.
          for (final ProfileEntity profile in data)
            if (!profile.isPupil)
              PlayerIdentity(
                id: profile.id,
                nickname: profile.nickname,
                avatarKey: profile.avatar.name,
                colorKey: profile.color.name,
              ),
        ]),
      DataFailed<List<ProfileEntity>>(:final exception) =>
        DataFailed<List<PlayerIdentity>>(exception),
    };
  }
}
