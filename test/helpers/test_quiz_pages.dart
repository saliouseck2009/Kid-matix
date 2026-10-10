import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/quiz/domain/repositories/quiz_session_repository.dart';
import 'package:kid_matix/features/quiz/domain/usecases/abandon_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/complete_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_quiz_result_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_time_limit_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:kid_matix/features/quiz/presentation/quiz_pages.dart';

import '../features/quiz/helpers/quiz_fixtures.dart';

/// [PlayerSettingsService] that always answers [mode].
final class FixedPlayerSettings implements PlayerSettingsService {
  /// Creates the service.
  const FixedPlayerSettings([
    this.mode = TimerMode.normal,
    this.isEverythingUnlocked = false,
  ]);

  /// Timer mode returned.
  final TimerMode mode;

  /// "Tout débloquer" returned.
  final bool isEverythingUnlocked;

  @override
  Future<DataState<bool>> readEverythingUnlocked({
    required String profileId,
  }) async => DataSuccess<bool>(isEverythingUnlocked);

  @override
  Future<DataState<TimerMode>> readTimerMode({
    required String profileId,
  }) async => DataSuccess<TimerMode>(mode);
}

/// [Ticker] that never ticks, so widget tests control time themselves.
final class SilentTicker implements Ticker {
  /// Creates the ticker.
  const SilentTicker();

  @override
  Stream<int> tick({required Duration interval}) => const Stream<int>.empty();
}

/// Use cases of the quiz over the real multiplication domain, a seeded
/// draw and [repository].
QuizUseCases buildTestQuizUseCases({
  required QuizSessionRepository repository,
  PlayerSettingsService settings = const FixedPlayerSettings(),
}) {
  final FakeClock clock = FakeClock(quizStart);
  return QuizUseCases(
    getTimeLimit: GetTimeLimitUseCase(settings: settings),
    buildQuiz: buildQuizUseCase(),
    submitAnswer: buildSubmitAnswerUseCase(),
    completeSession: CompleteSessionUseCase(
      repository: repository,
      clock: clock,
    ),
    abandonSession: AbandonSessionUseCase(repository: repository, clock: clock),
  );
}

/// Quiz pages over the real multiplication domain, a seeded draw and
/// [repository] (a mock by default).
QuizPages buildTestQuizPages({
  QuizSessionRepository? repository,
  Ticker ticker = const SilentTicker(),
  PlayerSettingsService settings = const FixedPlayerSettings(),
}) {
  final QuizSessionRepository sessions =
      repository ?? MockQuizSessionRepository();
  return QuizPages(
    useCases: buildTestQuizUseCases(repository: sessions, settings: settings),
    getResult: GetQuizResultUseCase(repository: sessions),
    ticker: ticker,
    domains: buildDomainRegistry(),
  );
}
