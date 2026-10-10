import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/usecases/abandon_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/complete_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_time_limit_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:mocktail/mocktail.dart' hide Answer;

import '../helpers/quiz_fixtures.dart';

/// [Ticker] whose ticks the test sends by hand.
final class _FakeTicker implements Ticker {
  final StreamController<int> controller = StreamController<int>.broadcast();

  @override
  Stream<int> tick({required Duration interval}) => controller.stream;
}

final class _MockSettings extends Mock implements PlayerSettingsService {}

/// Ticks in a minute: the whole quiz.
const int _ticksPerMinute = 600;

final QuizRequest _clockRequest = QuizRequest(
  profileId: 'profile-1',
  domainId: MultiplicationDomain.domainId,
  mode: QuizMode.timeAttack,
  itemKeys: tableKeys(5),
  questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
  questionCount: 40,
  totalTimeLimit: const Duration(seconds: 60),
);

void main() {
  late _FakeTicker ticker;
  late MockQuizSessionRepository mockRepository;
  late QuizBloc bloc;

  setUpAll(registerQuizFallbacks);

  setUp(() {
    ticker = _FakeTicker();
    final _MockSettings mockSettings = _MockSettings();
    mockRepository = MockQuizSessionRepository();
    when(
      () => mockSettings.readTimerMode(profileId: any(named: 'profileId')),
    ).thenAnswer((_) async => const DataSuccess<TimerMode>(TimerMode.normal));
    when(
      () => mockRepository.saveSession(
        session: any(named: 'session'),
        answers: any(named: 'answers'),
      ),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
    final FakeClock clock = FakeClock(quizStart);
    bloc = QuizBloc(
      useCases: QuizUseCases(
        getTimeLimit: GetTimeLimitUseCase(settings: mockSettings),
        buildQuiz: buildQuizUseCase(),
        submitAnswer: buildSubmitAnswerUseCase(),
        completeSession: CompleteSessionUseCase(
          repository: mockRepository,
          clock: clock,
        ),
        abandonSession: AbandonSessionUseCase(
          repository: mockRepository,
          clock: clock,
        ),
      ),
      ticker: ticker,
    );
  });

  tearDown(() async {
    await bloc.close();
    await ticker.controller.close();
  });

  Future<QuizAsking> start() async {
    bloc.add(QuizStarted(request: _clockRequest));
    await pumpEventQueue();
    return bloc.state as QuizAsking;
  }

  Future<void> tick(int count) async {
    for (int index = 0; index < count; index++) {
      ticker.controller.add(index);
      await pumpEventQueue();
    }
  }

  Future<void> answer({required bool isRight}) async {
    final QuizAsking asking = bloc.state as QuizAsking;
    final int expected =
        (asking.turn.question.expectedAnswer as NumberAnswer).value;
    bloc.add(
      AnswerSubmitted(answer: NumberAnswer(expected + (isRight ? 0 : 1))),
    );
    await pumpEventQueue();
  }

  group('QuizBloc against the clock', () {
    test(
      'counts the time of the whole quiz, with no time per question',
      () async {
        // Arrange
        await start();
        // Act
        await tick(25);
        // Assert
        final QuizAsking actualState = bloc.state as QuizAsking;
        expect(actualState.run.timeLimit, isNull);
        expect(actualState.playedTime, const Duration(milliseconds: 2500));
      },
    );
    test('asks the next question by itself after a right answer', () async {
      // Arrange
      await start();
      await tick(10);
      await answer(isRight: true);
      // Act
      await tick(6);
      // Assert
      final QuizAsking actualState = bloc.state as QuizAsking;
      expect(actualState.run.answers, hasLength(1));
      expect(actualState.playedTime, const Duration(milliseconds: 1600));
    });
    test('shows a mistake longer than a right answer', () async {
      // Arrange
      await start();
      await answer(isRight: false);
      // Act
      await tick(14);
      final QuizState actualDuring = bloc.state;
      await tick(1);
      // Assert
      expect(actualDuring, isA<QuizShowingFeedback>());
      expect(bloc.state, isA<QuizAsking>());
    });
    test('never brings a missed fact back', () async {
      // Arrange
      await start();
      // Act
      await answer(isRight: false);
      await tick(15);
      // Assert
      final QuizAsking actualState = bloc.state as QuizAsking;
      expect(
        actualState.run.queue.where((QuizTurn turn) => turn.isRetry),
        isEmpty,
      );
    });
    test('ends at 60 seconds and saves the answers given', () async {
      // Arrange
      await start();
      await answer(isRight: true);
      await tick(6);
      await answer(isRight: true);
      await tick(6);
      await answer(isRight: false);
      // Act
      await tick(_ticksPerMinute - 12);
      // Assert
      expect(bloc.state, isA<QuizCompleted>());
      final QuizSessionEntity actualSession =
          (bloc.state as QuizCompleted).session;
      expect(actualSession.mode, QuizMode.timeAttack);
      expect(actualSession.correctCount, 2);
      expect(actualSession.questionCount, 3);
    });
    test('stops the time while the app is in the background', () async {
      // Arrange
      await start();
      await tick(10);
      // Act
      bloc.add(const QuizPaused());
      await pumpEventQueue();
      await tick(50);
      // Assert
      final QuizAsking actualState = bloc.state as QuizAsking;
      expect(actualState.isPaused, isTrue);
      expect(actualState.playedTime, const Duration(seconds: 1));
    });
    test('replaces the question shown when the app comes back', () async {
      // Arrange
      final QuizAsking inputState = await start();
      await tick(10);
      bloc.add(const QuizPaused());
      await pumpEventQueue();
      // Act
      bloc.add(const QuizResumed());
      await pumpEventQueue();
      await tick(1);
      // Assert
      final QuizAsking actualState = bloc.state as QuizAsking;
      expect(actualState.isPaused, isFalse);
      expect(actualState.run.answers, isEmpty);
      expect(
        actualState.run.queue,
        hasLength(inputState.run.queue.length - 1),
      );
      expect(actualState.playedTime, const Duration(milliseconds: 1100));
    });
    test('holds the feedback while the app is in the background', () async {
      // Arrange
      await start();
      await answer(isRight: true);
      // Act
      bloc.add(const QuizPaused());
      await pumpEventQueue();
      await tick(20);
      // Assert
      expect(bloc.state, isA<QuizShowingFeedback>());
    });
  });
}
