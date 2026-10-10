import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// Saves the game settings of a player; the next quiz, the map and the
/// daily goal follow them.
class UpdateSettingsUseCase
    implements UseCase<DataState<void>, ProfileSettingsEntity> {
  /// Creates the use case.
  const UpdateSettingsUseCase({required this._repository});

  final ProfileRepository _repository;

  @override
  Future<DataState<void>> call({required ProfileSettingsEntity params}) {
    return _repository.updateProfileSettings(settings: params);
  }
}
