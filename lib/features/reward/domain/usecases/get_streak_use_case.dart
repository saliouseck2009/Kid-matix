import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_summary.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:kid_matix/features/reward/domain/services/streak_policy.dart';

/// Returns the streak of a player as shown today; takes the profile id.
class GetStreakUseCase implements UseCase<DataState<StreakSummary>, String> {
  /// Creates the use case.
  const GetStreakUseCase({
    required this._repository,
    required this._clock,
    this._policy = const StreakPolicy(),
  });

  final RewardRepository _repository;
  final Clock _clock;
  final StreakPolicy _policy;

  @override
  Future<DataState<StreakSummary>> call({required String params}) async {
    final DataState<StreakEntity> streak = await _repository.getStreak(
      profileId: params,
    );
    final DateTime now = _clock.now();
    return switch (streak) {
      DataSuccess<StreakEntity>(:final data) => DataSuccess<StreakSummary>(
        StreakSummary(
          current: _policy.currentAt(streak: data, now: now),
          best: data.best,
          isJokerAvailable: _policy.isJokerAvailable(streak: data, now: now),
        ),
      ),
      DataFailed<StreakEntity>(:final exception) => DataFailed<StreakSummary>(
        exception,
      ),
    };
  }
}
