import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_limits.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/nickname_checker.dart';

/// Creates a new player with default settings.
///
/// Fails with a `LimitReachedException` when the device already holds
/// [ProfileLimits.maxProfiles] profiles, a `ValidationException` when the
/// nickname breaks the rules, and a `ConflictException` when it is taken.
class CreateProfileUseCase
    implements UseCase<DataState<ProfileEntity>, CreateProfileParams> {
  /// Creates the use case.
  const CreateProfileUseCase({
    required this._repository,
    required this._nicknameChecker,
    required this._idGenerator,
    required this._clock,
  });

  final ProfileRepository _repository;
  final NicknameChecker _nicknameChecker;
  final IdGenerator _idGenerator;
  final Clock _clock;

  @override
  Future<DataState<ProfileEntity>> call({
    required CreateProfileParams params,
  }) async {
    final AppException? problem =
        await _findLimitProblem() ??
        await _nicknameChecker.findProblem(nickname: params.nickname);
    if (problem != null) return DataFailed<ProfileEntity>(problem);
    final ProfileEntity profile = ProfileEntity.newPlayer(
      id: _idGenerator.generateId(),
      nickname: NicknameRules.clean(params.nickname),
      avatar: params.avatar,
      color: params.color,
      createdAt: _clock.now(),
    );
    final DataState<ProfileEntity> created = await _repository.createProfile(
      profile: profile,
    );
    if (created is DataSuccess<ProfileEntity> && params.isReadAloudEnabled) {
      await _turnReadAloudOn(profile.id);
    }
    return created;
  }

  /// Applies the offer accepted in the creation form. The player exists
  /// by now, so a failure here is not worth failing the creation: the
  /// setting stays off and the settings screen can turn it on.
  Future<void> _turnReadAloudOn(String profileId) {
    return _repository.updateProfileSettings(
      settings: ProfileSettingsEntity.defaults(
        profileId: profileId,
      ).copyWith(isReadAloudEnabled: true),
    );
  }

  Future<AppException?> _findLimitProblem() async {
    final DataState<int> countState = await _repository.countProfiles();
    return switch (countState) {
      DataFailed<int>(:final exception) => exception,
      DataSuccess<int>(:final int data)
          when data >= ProfileLimits.maxProfiles =>
        const LimitReachedException(message: 'Too many profiles.'),
      DataSuccess<int>() => null,
    };
  }
}
