import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// [PlayerSettingsService] over the stored profile settings.
final class PlayerSettingsServiceImpl implements PlayerSettingsService {
  /// Creates the service over [repository].
  const PlayerSettingsServiceImpl({required this._repository});

  final ProfileRepository _repository;

  @override
  Future<DataState<TimerMode>> readTimerMode({
    required String profileId,
  }) async {
    final DataState<ProfileSettingsEntity> settings = await _repository
        .getProfileSettings(profileId: profileId);
    return switch (settings) {
      DataSuccess<ProfileSettingsEntity>(:final data) => DataSuccess<TimerMode>(
        data.timerMode,
      ),
      DataFailed<ProfileSettingsEntity>(:final exception) =>
        DataFailed<TimerMode>(exception),
    };
  }
}
