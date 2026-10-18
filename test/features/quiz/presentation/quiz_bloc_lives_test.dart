import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_time_schedule.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/usecases/abandon_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/complete_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_time_limit_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_clock.dart';
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

const QuizTimeSchedule _schedule = QuizTimeSchedule(
  start: Duration(seconds: 10),
  step: Duration(milliseconds: 500),
  stepEvery: 5,
  floor: Duration(seconds: 4),
);

final QuizRequest _livesRequest = QuizRequest(
  profileId: 'profile-1',
  domainId: MultiplicationDomain.domainId,
  mode: QuizMode.survival,
  itemKeys: tableKeys(5),
  questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
  questionCount: 40,
  baseTimeLimit: _schedule.start,
  keepsTimer: true,
  lives: 3,
  timeSchedule: _schedule,
);

/// Ticks of a right answer's feedback, and of a mistake's.
const int _rightFeedbackTicks = 6;
const int _wrongFeedbackTicks = 15;

void main() {
  late _FakeTicker ticker;
  late _MockSettings mockSettings;
  late MockQuizSessionRepository mockRepository;
  late QuizBloc bloc;

  setUpAll(registerQuizFallbacks);

  setUp(() {
    ticker = _FakeTicker();
    mockSettings = _MockSettings();
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
    bloc.add(QuizStarted(request: _livesRequest));
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
    await tick(isRight ? _rightFeedbackTicks : _wrongFeedbackTicks);
  }

  int ticksOf(Duration time) =>
      time.inMilliseconds ~/ QuizClock.tickInterval.inMilliseconds;

  void useTimerMode(TimerMode mode) {
    when(
      () => mockSettings.readTimerMode(profileId: any(named: 'profileId')),
    ).thenAnswer((_) async => DataSuccess<TimerMode>(mode));
  }

  group('QuizBloc with lives', () {
    test('takes a life when the time runs out and goes on', () async {
      // Arrange
      await start();
      // Act
      await tick(ticksOf(_schedule.start));
      final QuizState actualFeedback = bloc.state;
      await tick(_wrongFeedbackTicks);
      // Assert
      expect(actualFeedback, isA<QuizShowingFeedback>());
      final QuizAsking actualState = bloc.state as QuizAsking;
      expect(actualState.run.answers.single.isTimedOut, isTrue);
      expect(actualState.run.livesLeft, 2);
    });
    test('gives 9.5 seconds after 5 right answers', () async {
      // Arrange
      await start();
      for (int index = 0; index < 5; index++) {
        await answer(isRight: true);
      }
      // Act
      await tick(94);
      final QuizState actualBefore = bloc.state;
      await tick(1);
      // Assert
      expect(actualBefore, isA<QuizAsking>());
      expect(
        (actualBefore as QuizAsking).run.currentTimeLimit,
        const Duration(milliseconds: 9500),
      );
      expect(bloc.state, isA<QuizShowingFeedback>());
    });
    test('ends at the third mistake and saves the game', () async {
      // Arrange
      await start();
      await answer(isRight: false);
      await answer(isRight: true);
      await answer(isRight: false);
      // Act
      await answer(isRight: false);
      // Assert
      expect(bloc.state, isA<QuizCompleted>());
      final QuizSessionEntity actualSession =
          (bloc.state as QuizCompleted).session;
      expect(actualSession.mode, QuizMode.survival);
      expect(actualSession.correctCount, 1);
      expect(actualSession.questionCount, 4);
    });
    test('gives 15 seconds with the relaxed timer', () async {
      // Arrange
      useTimerMode(TimerMode.relaxed);
      // Act
      final QuizAsking actualState = await start();
      // Assert
      expect(actualState.run.currentTimeLimit, const Duration(seconds: 15));
      expect(actualState.run.timeSchedule!.floor, const Duration(seconds: 6));
    });
    test('keeps its timer when the player turned the timer off', () async {
      // Arrange
      useTimerMode(TimerMode.off);
      // Act
      final QuizAsking actualState = await start();
      // Assert
      expect(actualState.run.currentTimeLimit, _schedule.start);
    });
    test('replaces the question shown after the background', () async {
      // Arrange
      final QuizAsking inputState = await start();
      await tick(30);
      bloc.add(const QuizPaused());
      await pumpEventQueue();
      // Act
      bloc.add(const QuizResumed());
      await pumpEventQueue();
      // Assert
      final QuizAsking actualState = bloc.state as QuizAsking;
      expect(actualState.elapsed, Duration.zero);
      expect(actualState.run.answers, isEmpty);
      expect(actualState.run.livesLeft, 3);
      expect(
        actualState.run.queue,
        hasLength(inputState.run.queue.length - 1),
      );
    });
  });
}
