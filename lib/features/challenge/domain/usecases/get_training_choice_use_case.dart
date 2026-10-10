import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/open_units_service.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/repositories/training_choice_repository.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_rules.dart';

/// The free training to offer a player: their last choice, or else the
/// last table open on their path, the fewest questions and the timer of
/// their settings.
class GetTrainingChoiceUseCase
    implements UseCase<DataState<TrainingSource>, String> {
  /// Creates the use case.
  const GetTrainingChoiceUseCase({
    required this._repository,
    required this._openUnits,
    required this._settings,
  });

  final TrainingChoiceRepository _repository;
  final OpenUnitsService _openUnits;
  final PlayerSettingsService _settings;

  /// Returns the choice to offer the player [params].
  @override
  Future<DataState<TrainingSource>> call({required String params}) async {
    final DataState<TrainingSource?> saved = await _repository.getChoice(
      profileId: params,
    );
    if (saved case DataSuccess<TrainingSource?>(:final TrainingSource data)) {
      return DataSuccess<TrainingSource>(data);
    }
    final DataState<List<String>> open = await _openUnits.readOpenUnitKeys(
      profileId: params,
    );
    final DataState<TimerMode> timer = await _settings.readTimerMode(
      profileId: params,
    );
    return switch (open) {
      DataSuccess<List<String>>(:final data) => DataSuccess<TrainingSource>(
        TrainingSource(
          unitKeys: data.isEmpty ? const <String>[] : <String>[data.last],
          questionCount: ChallengeRules.trainingQuestionCounts.first,
          hasTimer: switch (timer) {
            DataSuccess<TimerMode>(data: TimerMode.off) => false,
            _ => true,
          },
        ),
      ),
      DataFailed<List<String>>(:final exception) => DataFailed<TrainingSource>(
        exception,
      ),
    };
  }
}
