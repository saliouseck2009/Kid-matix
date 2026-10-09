import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// Makes a player the active one, remembered across app launches.
///
/// Takes the identifier of the chosen profile and returns that profile.
/// Fails with a `NotFoundException` when it does not exist.
class SelectProfileUseCase
    implements UseCase<DataState<ProfileEntity>, String> {
  /// Creates the use case over [repository].
  const SelectProfileUseCase({required this._repository});

  final ProfileRepository _repository;

  @override
  Future<DataState<ProfileEntity>> call({required String params}) async {
    final DataState<ProfileEntity> profileState = await _repository.getProfile(
      profileId: params,
    );
    if (profileState is DataFailed<ProfileEntity>) return profileState;
    final DataState<void> savedState = await _repository.setActiveProfileId(
      profileId: params,
    );
    return switch (savedState) {
      DataSuccess<void>() => profileState,
      DataFailed<void>(:final exception) => DataFailed<ProfileEntity>(
        exception,
      ),
    };
  }
}
