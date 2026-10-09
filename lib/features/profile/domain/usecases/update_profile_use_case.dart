import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';
import 'package:kid_matix/features/profile/domain/usecases/nickname_checker.dart';

/// Saves a renamed player or a new avatar or color.
///
/// Takes the edited profile. Fails with a `ValidationException` when the
/// nickname breaks the rules and a `ConflictException` when another player
/// already uses it.
class UpdateProfileUseCase
    implements UseCase<DataState<ProfileEntity>, ProfileEntity> {
  /// Creates the use case.
  const UpdateProfileUseCase({
    required this._repository,
    required this._nicknameChecker,
  });

  final ProfileRepository _repository;
  final NicknameChecker _nicknameChecker;

  @override
  Future<DataState<ProfileEntity>> call({
    required ProfileEntity params,
  }) async {
    final AppException? problem = await _nicknameChecker.findProblem(
      nickname: params.nickname,
      excludedProfileId: params.id,
    );
    if (problem != null) return DataFailed<ProfileEntity>(problem);
    return _repository.updateProfile(
      profile: params.copyWith(nickname: NicknameRules.clean(params.nickname)),
    );
  }
}
