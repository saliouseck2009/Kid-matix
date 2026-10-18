import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/open_units_service.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/survival_challenge_entity.dart';

/// The survival game of a player: on every table open on their path, like
/// the time attack (owner's choice), so the record grows with them.
class GetSurvivalUseCase
    implements UseCase<DataState<SurvivalChallengeEntity>, String> {
  /// Creates the use case.
  const GetSurvivalUseCase({
    required this._openUnits,
    required this._settings,
  });

  final OpenUnitsService _openUnits;
  final PlayerSettingsService _settings;

  /// Returns the survival game of the player [params]. When the timer
  /// setting cannot be read, the game is offered without the note.
  @override
  Future<DataState<SurvivalChallengeEntity>> call({
    required String params,
  }) async {
    final DataState<List<String>> open = await _openUnits.readOpenUnitKeys(
      profileId: params,
    );
    final DataState<TimerMode> timer = await _settings.readTimerMode(
      profileId: params,
    );
    return switch (open) {
      DataSuccess<List<String>>(:final data) =>
        DataSuccess<SurvivalChallengeEntity>(
          SurvivalChallengeEntity(
            source: SurvivalSource(unitKeys: data),
            keepsTimerTurnedOff: switch (timer) {
              DataSuccess<TimerMode>(data: TimerMode.off) => true,
              _ => false,
            },
          ),
        ),
      DataFailed<List<String>>(:final exception) =>
        DataFailed<SurvivalChallengeEntity>(exception),
    };
  }
}
