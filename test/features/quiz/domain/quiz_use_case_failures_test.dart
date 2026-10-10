import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/usecases/complete_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_time_limit_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/quiz_fixtures.dart';

final class _MockPlayerSettingsService extends Mock
    implements PlayerSettingsService {}

const CacheException _failure = CacheException(message: 'disk error');

void main() {
  setUpAll(registerQuizFallbacks);

  group('CompleteSessionUseCase', () {
    test('passes on a failure to save the session', () async {
      // Arrange
      final MockQuizSessionRepository mockRepository =
          MockQuizSessionRepository();
      when(
        () => mockRepository.saveSession(
          session: any(named: 'session'),
          answers: any(named: 'answers'),
        ),
      ).thenAnswer((_) async => const DataFailed<void>(_failure));
      final QuizRun inputRun = (await buildRun(<String>['mul:5x1'])).stopped();
      final CompleteSessionUseCase useCase = CompleteSessionUseCase(
        repository: mockRepository,
        clock: FakeClock(quizStart),
      );
      // Act
      final DataState<QuizSessionEntity> actualState = await useCase(
        params: inputRun,
      );
      // Assert
      expect(actualState.exceptionOrNull, _failure);
    });
  });

  group('GetTimeLimitUseCase', () {
    test('keeps the base time when the settings cannot be read', () async {
      // Arrange
      final _MockPlayerSettingsService mockSettings =
          _MockPlayerSettingsService();
      when(
        () => mockSettings.readTimerMode(profileId: any(named: 'profileId')),
      ).thenAnswer((_) async => const DataFailed<TimerMode>(_failure));
      const Duration expectedLimit = Duration(seconds: 8);
      const QuizRequest inputRequest = QuizRequest(
        profileId: 'p1',
        domainId: 'multiplication',
        mode: QuizMode.freeTraining,
        itemKeys: <String>['mul:5x1'],
        questionTypeIds: <String>[QuestionTypeIds.typedAnswer],
        baseTimeLimit: expectedLimit,
      );
      final GetTimeLimitUseCase useCase = GetTimeLimitUseCase(
        settings: mockSettings,
      );
      // Act
      final Duration? actualLimit = await useCase(params: inputRequest);
      // Assert
      expect(actualLimit, expectedLimit);
    });
  });
}
