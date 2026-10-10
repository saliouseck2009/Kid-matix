import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// The game settings of a player; takes the profile id.
class GetSettingsUseCase
    implements UseCase<DataState<ProfileSettingsEntity>, String> {
  /// Creates the use case.
  const GetSettingsUseCase({required this._repository});

  final ProfileRepository _repository;

  @override
  Future<DataState<ProfileSettingsEntity>> call({required String params}) {
    return _repository.getProfileSettings(profileId: params);
  }
}
