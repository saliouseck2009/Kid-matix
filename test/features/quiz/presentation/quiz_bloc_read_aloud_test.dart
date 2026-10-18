import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/domain/usecases/abandon_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/complete_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_time_limit_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_read_aloud.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_spoken_text.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:mocktail/mocktail.dart' hide Answer;

import '../../../helpers/fake_speech_service.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../helpers/quiz_fixtures.dart';

/// [Ticker] whose ticks the test sends by hand.
final class _FakeTicker implements Ticker {
  final StreamController<int> controller = StreamController<int>.broadcast();

  @override
  Stream<int> tick({required Duration interval}) => controller.stream;
}

/// [QuizSpokenText] that says the key of the item, so a test sees which
/// question was read.
final class _KeyedSpokenText implements QuizSpokenText {
  const _KeyedSpokenText();

  @override
  String ofQuestion(Question question) => 'question ${question.itemKey}';

  @override
  String? ofInstruction(Question question) => 'instruction ${question.itemKey}';
}

final class _MockSettings extends Mock implements PlayerSettingsService {}

QuizRequest _request({Duration? baseTimeLimit}) {
  return QuizRequest(
    profileId: 'profile-1',
    domainId: MultiplicationDomain.domainId,
    mode: QuizMode.freeTraining,
    itemKeys: tableKeys(5),
    questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
    baseTimeLimit: baseTimeLimit ?? QuizTimeLimits.freeTraining,
  );
}

void main() {
  late _FakeTicker ticker;
  late FakeSpeechService speech;
  late MockQuizSessionRepository mockRepository;
  late QuizBloc bloc;

  setUpAll(registerQuizFallbacks);

  setUp(() {
    ticker = _FakeTicker();
    speech = FakeSpeechService();
    mockRepository = MockQuizSessionRepository();
    when(
      () => mockRepository.saveSession(
        session: any(named: 'session'),
        answers: any(named: 'answers'),
      ),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
  });

  tearDown(() async {
    await bloc.close();
    await ticker.controller.close();
  });

  QuizBloc buildBloc({
    bool readsByItself = false,
    bool hasReadAloud = true,
  }) {
    final _MockSettings settings = _MockSettings();
    when(
      () => settings.readTimerMode(profileId: any(named: 'profileId')),
    ).thenAnswer((_) async => const DataSuccess<TimerMode>(TimerMode.normal));
    final FakeClock clock = FakeClock(quizStart);
    return bloc = QuizBloc(
      useCases: QuizUseCases(
        getTimeLimit: GetTimeLimitUseCase(settings: settings),
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
      readAloud: hasReadAloud
          ? QuizReadAloud(
              useCases: buildReadAloudUseCases(
                speech: speech,
                readsByItself: readsByItself,
              ),
              languageCode: 'fr',
              text: const _KeyedSpokenText(),
            )
          : null,
    );
  }

  Future<QuizAsking> start({QuizRequest? request}) async {
    bloc.add(QuizStarted(request: request ?? _request()));
    await pumpEventQueue();
    return bloc.state as QuizAsking;
  }

  QuizAsking asking() => bloc.state as QuizAsking;

  group('QuizBloc with a voice', () {
    test('offers the listen button when a voice is installed', () async {
      // Arrange
      buildBloc();
      // Act
      final QuizAsking actualState = await start();
      // Assert
      expect(actualState.canReadAloud, isTrue);
      expect(actualState.isReading, isFalse);
    });
    test('hides the listen button, without an error, with no voice', () async {
      // Arrange
      speech.hasVoice = false;
      buildBloc();
      // Act
      final QuizAsking actualState = await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Assert
      expect(actualState.canReadAloud, isFalse);
      expect(asking().isReading, isFalse);
      expect(speech.spoken, isEmpty);
    });
    test(
      'has no listen button when the quiz is built without a voice',
      () async {
        // Arrange
        buildBloc(hasReadAloud: false);
        // Act
        final QuizAsking actualState = await start();
        bloc.add(const ReadAloudToggled());
        await pumpEventQueue();
        // Assert
        expect(actualState.canReadAloud, isFalse);
        expect(speech.spoken, isEmpty);
      },
    );
    test(
      'reads the question in the language when the button is tapped',
      () async {
        // Arrange
        buildBloc();
        await start();
        // Act
        bloc.add(const ReadAloudToggled());
        await pumpEventQueue();
        // Assert
        expect(speech.spoken, <String>['question mul:5x1']);
        expect(speech.languages, <String>['fr']);
        expect(asking().isReading, isTrue);
      },
    );
    test('goes back to not reading when the voice is done', () async {
      // Arrange
      buildBloc();
      await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Act
      speech.finishReading();
      await pumpEventQueue();
      // Assert
      expect(asking().isReading, isFalse);
    });
    test('stops the reading when the button is tapped again', () async {
      // Arrange
      buildBloc();
      await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Act
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Assert
      expect(speech.stopCount, 1);
      expect(speech.isSpeaking, isFalse);
      expect(asking().isReading, isFalse);
    });
    test('reads the question again after a first reading', () async {
      // Arrange
      buildBloc();
      await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      speech.finishReading();
      await pumpEventQueue();
      // Act
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Assert
      expect(speech.spoken, hasLength(2));
      expect(asking().isReading, isTrue);
    });
    test('silences the voice when the question is answered', () async {
      // Arrange
      buildBloc();
      await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Act
      bloc.add(
        AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
      );
      await pumpEventQueue();
      // Assert
      expect(bloc.state, isA<QuizShowingFeedback>());
      expect(speech.isSpeaking, isFalse);
    });
    test('ignores the late end of a reading of the last question', () async {
      // Arrange: a voice that only ends the old reading when a new one starts.
      speech.ignoresStop = true;
      buildBloc();
      await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      bloc.add(
        AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
      );
      await pumpEventQueue();
      bloc.add(const NextRequested());
      await pumpEventQueue();
      // Act
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Assert
      expect(speech.spoken, hasLength(2));
      expect(asking().turn.question.itemKey, isNot('mul:5x1'));
      expect(asking().isReading, isTrue);
    });
    test('silences the voice when the app goes to the background', () async {
      // Arrange
      buildBloc();
      await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Act
      bloc.add(const QuizPaused());
      await pumpEventQueue();
      // Assert
      expect(speech.isSpeaking, isFalse);
      expect(asking().isReading, isFalse);
      expect(asking().isPaused, isTrue);
    });
    test('silences the voice when the player leaves the quiz', () async {
      // Arrange
      buildBloc();
      await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Act
      bloc.add(const QuizAbandoned());
      await pumpEventQueue();
      // Assert
      expect(speech.isSpeaking, isFalse);
      expect(bloc.state, isA<QuizLeft>());
    });
    test('silences the voice when the screen closes', () async {
      // Arrange
      buildBloc();
      await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Act
      await bloc.close();
      // Assert
      expect(speech.isSpeaking, isFalse);
    });
  });
}
