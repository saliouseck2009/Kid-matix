import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/settings_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/settings_use_cases.dart';

/// Reads and saves the settings of a player, erases their progress or
/// deletes them.
///
/// A change shows at once and is saved behind; a failed save puts the
/// previous settings back. Deleting changes the profile session and the
/// router leaves the screen.
final class SettingsCubit extends Cubit<SettingsState> {
  /// Creates the Cubit of the player [profileId].
  SettingsCubit({required this._profileId, required this._useCases})
    : super(const SettingsLoading());

  final String _profileId;
  final SettingsUseCases _useCases;

  /// Reads the player and their settings.
  Future<void> load() async {
    emit(const SettingsLoading());
    final DataState<ProfileEntity> profile = await _useCases.getProfile(
      params: _profileId,
    );
    final DataState<ProfileSettingsEntity> settings = await _useCases
        .getSettings(params: _profileId);
    if (isClosed) return;
    emit(switch ((profile, settings)) {
      (
        DataSuccess<ProfileEntity>(data: final ProfileEntity player),
        DataSuccess<ProfileSettingsEntity>(
          data: final ProfileSettingsEntity values,
        ),
      ) =>
        SettingsLoaded(nickname: player.nickname, settings: values),
      (DataFailed<ProfileEntity>(:final exception), _) ||
      (
        _,
        DataFailed<ProfileSettingsEntity>(:final exception),
      ) => SettingsFailure(errorCode: exception.code),
    });
  }

  /// Applies [change] to the settings and saves them.
  Future<void> update(
    ProfileSettingsEntity Function(ProfileSettingsEntity settings) change,
  ) async {
    final SettingsState current = state;
    if (current is! SettingsLoaded) return;
    final ProfileSettingsEntity next = change(current.settings);
    emit(SettingsLoaded(nickname: current.nickname, settings: next));
    final DataState<void> saved = await _useCases.updateSettings(params: next);
    if (isClosed) return;
    if (saved case DataFailed<void>(:final exception)) {
      emit(
        SettingsLoaded(
          nickname: current.nickname,
          settings: current.settings,
          errorCode: exception.code,
        ),
      );
    }
  }

  /// Erases the progress of the player.
  Future<void> resetProgress() async {
    final SettingsState current = state;
    if (current is! SettingsLoaded) return;
    final DataState<void> reset = await _useCases.resetProgress(
      params: _profileId,
    );
    if (isClosed) return;
    emit(
      SettingsLoaded(
        nickname: current.nickname,
        settings: current.settings,
        wasReset: reset is DataSuccess<void>,
        errorCode: switch (reset) {
          DataFailed<void>(:final exception) => exception.code,
          DataSuccess<void>() => null,
        },
      ),
    );
  }

  /// Deletes the player and all of their data.
  Future<void> deleteProfile() async {
    final SettingsState current = state;
    if (current is! SettingsLoaded) return;
    emit(const SettingsLoading());
    final DataState<void> deleted = await _useCases.deleteProfile(
      params: _profileId,
    );
    if (isClosed) return;
    if (deleted case DataFailed<void>(:final exception)) {
      emit(
        SettingsLoaded(
          nickname: current.nickname,
          settings: current.settings,
          errorCode: exception.code,
        ),
      );
    }
  }
}
