import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/reward/domain/entities/daily_goal_progress.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:kid_matix/features/reward/domain/services/streak_policy.dart';

/// Returns the XP a player earned today against their daily goal; takes
/// the profile id.
class GetDailyGoalUseCase
    implements UseCase<DataState<DailyGoalProgress>, String> {
  /// Creates the use case.
  const GetDailyGoalUseCase({
    required this._repository,
    required this._settings,
    required this._clock,
  });

  final RewardRepository _repository;
  final PlayerSettingsService _settings;
  final Clock _clock;

  @override
  Future<DataState<DailyGoalProgress>> call({required String params}) async {
    final DataState<int> goal = await _settings.readDailyGoalXp(
      profileId: params,
    );
    if (goal case DataFailed<int>(:final exception)) {
      return DataFailed<DailyGoalProgress>(exception);
    }
    final DateTime today = StreakPolicy.dayOf(_clock.now());
    final DataState<int> earned = await _repository.getXpEarned(
      profileId: params,
      from: today,
      to: DateTime(today.year, today.month, today.day + 1),
    );
    return switch (earned) {
      DataSuccess<int>(:final data) => DataSuccess<DailyGoalProgress>(
        DailyGoalProgress(
          earnedXp: data,
          goalXp: (goal as DataSuccess<int>).data,
        ),
      ),
      DataFailed<int>(:final exception) => DataFailed<DailyGoalProgress>(
        exception,
      ),
    };
  }
}
