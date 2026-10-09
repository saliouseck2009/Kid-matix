import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
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
  int listenCount = 0;

  @override
  Stream<int> tick({required Duration interval}) {
    listenCount++;
    return controller.stream;
  }
}

final class _MockSettings extends Mock implements PlayerSettingsService {}

QuizRequest _request({
  List<String>? itemKeys,
  Duration? baseTimeLimit = QuizTimeLimits.freeTraining,
}) {
  return QuizRequest(
    profileId: 'profile-1',
    domainId: MultiplicationDomain.domainId,
    mode: QuizMode.freeTraining,
    itemKeys: itemKeys ?? tableKeys(5),
    questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
    baseTimeLimit: baseTimeLimit,
  );
}

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

  Future<QuizAsking> start({QuizRequest? request}) async {
    bloc.add(QuizStarted(request: request ?? _request()));
    await pumpEventQueue();
    return bloc.state as QuizAsking;
  }

  Future<void> tick(int count) async {
    for (int index = 0; index < count; index++) {
      ticker.controller.add(index);
    }
    await pumpEventQueue();
  }

  Answer expectedAnswer() {
    return (bloc.state as QuizAsking).turn.question.expectedAnswer;
  }

  group('QuizBloc', () {
    test('asks the first question with a running timer', () async {
      // Act
      final QuizAsking actualState = await start();
      // Assert
      expect(actualState.turn.question.itemKey, 'mul:5x1');
      expect(actualState.run.timeLimit, QuizTimeLimits.freeTraining);
      expect(actualState.remainingFraction, 1);
      expect(ticker.listenCount, 1);
    });
    test('measures the time spent on the question', () async {
      // Arrange
      await start();
      // Act
      await tick(25);
      // Assert
      final QuizAsking actualState = bloc.state as QuizAsking;
      expect(actualState.elapsed, const Duration(milliseconds: 2500));
      expect(actualState.remainingFraction, closeTo(0.75, 0.001));
      expect(actualState.isRunningOut, isFalse);
    });
    test('warns in the last 3 seconds', () async {
      // Arrange
      await start();
      // Act
      await tick(70);
      // Assert
      expect((bloc.state as QuizAsking).isRunningOut, isTrue);
    });
    test('shows a right answer with its time', () async {
      // Arrange
      await start();
      await tick(20);
      // Act
      bloc.add(AnswerSubmitted(answer: expectedAnswer()));
      await pumpEventQueue();
      // Assert
      final QuizShowingFeedback actualState = bloc.state as QuizShowingFeedback;
      expect(actualState.submission.answer.isCorrect, isTrue);
      expect(actualState.submission.answer.isLightning, isTrue);
      expect(
        actualState.submission.answer.answerTime,
        const Duration(seconds: 2),
      );
      expect(
        actualState.givenAnswer,
        actualState.submission.turn.question.expectedAnswer,
      );
    });
    test('shows a wrong answer and the right one', () async {
      // Arrange
      await start();
      // Act
      bloc.add(const AnswerSubmitted(answer: NumberAnswer(-1)));
      await pumpEventQueue();
      // Assert
      final QuizShowingFeedback actualState = bloc.state as QuizShowingFeedback;
      expect(actualState.submission.answer.isCorrect, isFalse);
      expect(
        actualState.submission.turn.question.expectedAnswer,
        const NumberAnswer(5),
      );
    });
    test('counts the end of the time as a mistake', () async {
      // Arrange
      await start();
      // Act
      await tick(100);
      // Assert
      final QuizShowingFeedback actualState = bloc.state as QuizShowingFeedback;
      expect(actualState.submission.answer.isTimedOut, isTrue);
      expect(actualState.givenAnswer, isNull);
    });
    test('stops the timer while the app is in the background', () async {
      // Arrange
      await start();
      await tick(10);
      // Act
      bloc.add(const QuizPaused());
      await pumpEventQueue();
      await tick(200);
      // Assert
      final QuizAsking actualState = bloc.state as QuizAsking;
      expect(actualState.isPaused, isTrue);
      expect(actualState.elapsed, const Duration(seconds: 1));
    });
    test('goes on with the timer when the app comes back', () async {
      // Arrange
      await start();
      await tick(10);
      bloc.add(const QuizPaused());
      await pumpEventQueue();
      // Act
      bloc.add(const QuizResumed());
      await pumpEventQueue();
      await tick(10);
      // Assert
      final QuizAsking actualState = bloc.state as QuizAsking;
      expect(actualState.isPaused, isFalse);
      expect(actualState.elapsed, const Duration(seconds: 2));
      expect(ticker.listenCount, 2);
    });
    test('moves to the next question with a fresh timer', () async {
      // Arrange
      await start();
      await tick(30);
      bloc.add(AnswerSubmitted(answer: expectedAnswer()));
      await pumpEventQueue();
      // Act
      bloc.add(const NextRequested());
      await pumpEventQueue();
      // Assert
      final QuizAsking actualState = bloc.state as QuizAsking;
      expect(actualState.turn.question.itemKey, 'mul:5x2');
      expect(actualState.elapsed, Duration.zero);
      expect(actualState.answeredCount, 1);
    });
    test('saves the session after the last question', () async {
      // Arrange
      await start(request: _request(itemKeys: <String>['mul:5x1']));
      bloc.add(AnswerSubmitted(answer: expectedAnswer()));
      await pumpEventQueue();
      // Act
      bloc.add(const NextRequested());
      await pumpEventQueue();
      // Assert
      final QuizCompleted actualState = bloc.state as QuizCompleted;
      expect(actualState.session.status, QuizSessionStatus.completed);
      expect(actualState.session.correctCount, 1);
    });
    test('keeps the answers given when the player leaves', () async {
      // Arrange
      await start();
      bloc.add(AnswerSubmitted(answer: expectedAnswer()));
      await pumpEventQueue();
      // Act
      bloc.add(const QuizAbandoned());
      await pumpEventQueue();
      // Assert
      expect(bloc.state, isA<QuizLeft>());
      verify(
        () => mockRepository.saveSession(
          session: any(named: 'session'),
          answers: any(named: 'answers'),
        ),
      ).called(1);
    });
    test('gives 15 seconds with the relaxed timer', () async {
      // Arrange
      when(
        () => mockSettings.readTimerMode(profileId: any(named: 'profileId')),
      ).thenAnswer(
        (_) async => const DataSuccess<TimerMode>(TimerMode.relaxed),
      );
      // Act
      final QuizAsking actualState = await start();
      // Assert
      expect(actualState.run.timeLimit, const Duration(seconds: 15));
    });
    test('shows no timer when the player turned it off', () async {
      // Arrange
      when(
        () => mockSettings.readTimerMode(profileId: any(named: 'profileId')),
      ).thenAnswer((_) async => const DataSuccess<TimerMode>(TimerMode.off));
      await start();
      // Act
      await tick(300);
      // Assert
      final QuizAsking actualState = bloc.state as QuizAsking;
      expect(actualState.run.timeLimit, isNull);
      expect(actualState.remainingFraction, isNull);
      expect(actualState.elapsed, const Duration(seconds: 30));
    });
    test('builds the number typed on the keypad', () async {
      // Arrange
      await start();
      // Act
      for (final int digit in <int>[0, 3, 5, 1, 7]) {
        bloc.add(DigitTyped(digit: digit));
      }
      bloc.add(const DigitErased());
      await pumpEventQueue();
      // Assert
      expect((bloc.state as QuizAsking).typedDigits, '35');
    });
    test('submits the typed number on validation', () async {
      // Arrange
      await start();
      bloc
        ..add(const DigitTyped(digit: 5))
        ..add(const TypedAnswerValidated());
      // Act
      await pumpEventQueue();
      // Assert
      final QuizShowingFeedback actualState = bloc.state as QuizShowingFeedback;
      expect(actualState.givenAnswer, const NumberAnswer(5));
      expect(actualState.submission.answer.isCorrect, isTrue);
    });
    test('ignores a validation with nothing typed', () async {
      // Arrange
      await start();
      // Act
      bloc.add(const TypedAnswerValidated());
      await pumpEventQueue();
      // Assert
      expect(bloc.state, isA<QuizAsking>());
    });
  });
}
