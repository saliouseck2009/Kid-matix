import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';

/// Time to answer each question of a quiz for its player.
///
/// Normal timer: the base time; relaxed: 1.5 times longer; off: no timer.
/// Returns `null` without a timer. When the settings cannot be read, the
/// normal timer applies.
class GetTimeLimitUseCase implements UseCase<Duration?, QuizRequest> {
  /// Creates the use case.
  const GetTimeLimitUseCase({required this._settings});

  final PlayerSettingsService _settings;

  @override
  Future<Duration?> call({required QuizRequest params}) async {
    final Duration? base = params.baseTimeLimit;
    if (base == null) return null;
    final DataState<TimerMode> mode = await _settings.readTimerMode(
      profileId: params.profileId,
    );
    return switch (mode) {
      DataSuccess<TimerMode>(data: TimerMode.normal) => base,
      DataSuccess<TimerMode>(data: TimerMode.relaxed) =>
        base *
            QuizTimeLimits.relaxedNumerator ~/
            QuizTimeLimits.relaxedDenominator,
      DataSuccess<TimerMode>(data: TimerMode.off) => null,
      DataFailed<TimerMode>() => base,
    };
  }
}
