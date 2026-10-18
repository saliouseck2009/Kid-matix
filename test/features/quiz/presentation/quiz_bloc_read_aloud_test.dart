import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/services/speech_service.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/speech/domain/services/speech_voices_unknown_exception.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/domain/usecases/abandon_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/complete_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_time_limit_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_read_aloud.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:mocktail/mocktail.dart' hide Answer;

import '../../../helpers/fake_mastery_service.dart';
import '../../../helpers/fake_speech_service.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../helpers/quiz_fixtures.dart';

/// [Ticker] whose ticks the test sends by hand.
final class _FakeTicker implements Ticker {
  final StreamController<int> controller = StreamController<int>.broadcast();

  @override
  Stream<int> tick({required Duration interval}) => controller.stream;
}

/// The sentence the quiz says for [question]: the key of its item, so a
/// test sees which question was read.
String _sayQuestion(Question question) => 'question ${question.itemKey}';

/// The instruction of [question]; none for a written answer.
String? _sayInstruction(Question question) {
  if (question.questionTypeId == QuestionTypeIds.typedAnswer) return null;
  return 'instruction ${question.itemKey}';
}

final class _MockSettings extends Mock implements PlayerSettingsService {}

/// A phone whose voice check itself fails.
final class _UnknownVoiceSpeech extends _BrokenSpeech {
  @override
  Future<bool> isAvailable({required String languageCode}) async {
    throw const SpeechVoicesUnknownException();
  }
}

/// A voice that is installed but fails when it has to speak.
final class _BrokenSpeech implements SpeechService {
  @override
  Future<bool> isAvailable({required String languageCode}) async => true;

  @override
  void forgetMissingVoices() {}

  @override
  SpeechReading speak({
    required String text,
    required String languageCode,
  }) {
    return SpeechReading(Future<void>.error(StateError('the voice broke')));
  }

  @override
  Future<void> stop({SpeechReading? reading}) async {}
}

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
  late FakeMasteryService mastery;
  late QuizBloc bloc;

  setUpAll(registerQuizFallbacks);

  setUp(() {
    ticker = _FakeTicker();
    speech = FakeSpeechService();
    mockRepository = MockQuizSessionRepository();
    mastery = FakeMasteryService();
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
    SpeechService? speechOverride,
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
        submitAnswer: buildSubmitAnswerUseCase(mastery: mastery),
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
                speech: speechOverride ?? speech,
                readsByItself: readsByItself,
              ),
              languageCode: 'fr',
              speakQuestion: _sayQuestion,
              speakInstruction: _sayInstruction,
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

  Future<void> tick(int count) async {
    for (int index = 0; index < count; index++) {
      ticker.controller.add(index);
    }
    await pumpEventQueue();
  }

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

  group('QuizBloc timer and reading', () {
    test('holds the timer until the voice has read the question', () async {
      // Arrange
      buildBloc(readsByItself: true);
      await start();
      // Act
      await tick(50);
      // Assert: the reading goes on, the time of the question did not start.
      expect(asking().isReading, isTrue);
      expect(asking().elapsed, Duration.zero);
      expect(asking().remainingFraction, 1);
      // Act: the voice is done, the timer starts.
      speech.finishReading();
      await pumpEventQueue();
      await tick(25);
      // Assert
      expect(asking().isReading, isFalse);
      expect(asking().elapsed, const Duration(milliseconds: 2500));
    });
    test('reads each new question by itself when the setting is on', () async {
      // Arrange
      buildBloc(readsByItself: true);
      await start();
      expect(speech.spoken, <String>['question mul:5x1']);
      speech.finishReading();
      await pumpEventQueue();
      // Act
      bloc.add(
        AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
      );
      await pumpEventQueue();
      bloc.add(const NextRequested());
      await pumpEventQueue();
      // Assert
      expect(speech.spoken, hasLength(2));
      expect(speech.spoken.last, startsWith('question mul:5x'));
      expect(speech.spoken.last, isNot('question mul:5x1'));
      expect(asking().isReading, isTrue);
    });
    test('does not read by itself when the setting is off', () async {
      // Arrange
      buildBloc();
      // Act
      await start();
      // Assert
      expect(speech.spoken, isEmpty);
      expect(asking().isReading, isFalse);
    });
    test('starts the timer at once when no voice is installed', () async {
      // Arrange: the setting is on, the voice is missing.
      speech.hasVoice = false;
      buildBloc(readsByItself: true);
      await start();
      // Act
      await tick(25);
      // Assert
      expect(speech.spoken, isEmpty);
      expect(asking().isReading, isFalse);
      expect(asking().elapsed, const Duration(milliseconds: 2500));
    });
    test('pauses the timer while the player listens again', () async {
      // Arrange
      buildBloc();
      await start();
      await tick(10);
      expect(asking().elapsed, const Duration(seconds: 1));
      // Act
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      await tick(50);
      // Assert
      expect(asking().elapsed, const Duration(seconds: 1));
      // Act
      speech.finishReading();
      await pumpEventQueue();
      await tick(5);
      // Assert
      expect(asking().elapsed, const Duration(milliseconds: 1500));
    });
    test('resumes the timer when the player stops the reading', () async {
      // Arrange
      buildBloc();
      await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Act
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      await tick(10);
      // Assert
      expect(asking().elapsed, const Duration(seconds: 1));
    });
    test('does not run out of time while the voice reads', () async {
      // Arrange: 10 seconds per question, a reading longer than that.
      buildBloc(readsByItself: true);
      await start();
      // Act
      await tick(150);
      // Assert
      expect(bloc.state, isA<QuizAsking>());
      expect(asking().elapsed, Duration.zero);
    });
    test('measures the answer time without the reading', () async {
      // Arrange
      buildBloc(readsByItself: true);
      await start();
      await tick(80);
      speech.finishReading();
      await pumpEventQueue();
      await tick(20);
      // Act
      bloc.add(
        AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
      );
      await pumpEventQueue();
      // Assert
      final QuizShowingFeedback actualState = bloc.state as QuizShowingFeedback;
      expect(
        actualState.submission.answer.answerTime,
        const Duration(seconds: 2),
      );
    });
    test(
      'counts an answer given at once during the reading as no time',
      () async {
        // Arrange
        buildBloc(readsByItself: true);
        await start();
        // Act
        bloc.add(
          AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
        );
        await pumpEventQueue();
        // Assert
        final QuizShowingFeedback actualState =
            bloc.state as QuizShowingFeedback;
        expect(actualState.submission.answer.isCorrect, isTrue);
        expect(actualState.submission.answer.answerTime, Duration.zero);
        expect(speech.isSpeaking, isFalse);
      },
    );
    test(
      'counts an answer given during the reading from the question',
      () async {
        // Arrange
        buildBloc(readsByItself: true);
        await start();
        await tick(20);
        // Act
        bloc.add(
          AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
        );
        await pumpEventQueue();
        // Assert: 2 seconds since the question appeared, reading included.
        final QuizShowingFeedback actualState =
            bloc.state as QuizShowingFeedback;
        expect(
          actualState.submission.answer.answerTime,
          const Duration(seconds: 2),
        );
        expect(actualState.submission.answer.isLightning, isTrue);
        expect(
          mastery.recordedAnswers.last.answerTime,
          const Duration(seconds: 2),
        );
      },
    );
    test('gives no lightning to an answer given late in the reading', () async {
      // Arrange
      buildBloc(readsByItself: true);
      await start();
      await tick(40);
      // Act
      bloc.add(
        AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
      );
      await pumpEventQueue();
      // Assert
      final QuizShowingFeedback actualState = bloc.state as QuizShowingFeedback;
      expect(
        actualState.submission.answer.answerTime,
        const Duration(seconds: 4),
      );
      expect(actualState.submission.answer.isLightning, isFalse);
      expect(
        mastery.recordedAnswers.last.answerTime,
        const Duration(seconds: 4),
      );
    });
    test('adds the time before the listen button to the answer time', () async {
      // Arrange
      buildBloc();
      await start();
      await tick(10);
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      await tick(15);
      // Act
      bloc.add(
        AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
      );
      await pumpEventQueue();
      // Assert: 1 second before the button, 1.5 seconds of reading.
      final QuizShowingFeedback actualState = bloc.state as QuizShowingFeedback;
      expect(
        actualState.submission.answer.answerTime,
        const Duration(milliseconds: 2500),
      );
    });
    test(
      'counts from the end of the reading when the answer comes after',
      () async {
        // Arrange
        buildBloc(readsByItself: true);
        await start();
        await tick(30);
        bloc.add(const ReadAloudToggled());
        await pumpEventQueue();
        expect(asking().isReading, isFalse);
        await tick(10);
        // Act
        bloc.add(
          AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
        );
        await pumpEventQueue();
        // Assert: the reading, stopped by the player, is not counted.
        final QuizShowingFeedback actualState =
            bloc.state as QuizShowingFeedback;
        expect(
          actualState.submission.answer.answerTime,
          const Duration(seconds: 1),
        );
      },
    );
    test(
      'charges the reading the player did not wait for to the clock',
      () async {
        // Arrange
        buildBloc(readsByItself: true);
        await start(
          request: QuizRequest(
            profileId: 'profile-1',
            domainId: MultiplicationDomain.domainId,
            mode: QuizMode.timeAttack,
            itemKeys: tableKeys(5),
            questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
            totalTimeLimit: const Duration(seconds: 60),
          ),
        );
        await tick(20);
        expect(asking().playedTime, Duration.zero);
        // Act
        bloc.add(
          AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
        );
        await pumpEventQueue();
        // Assert: 2 seconds of the reading went by before the answer.
        final QuizShowingFeedback actualState =
            bloc.state as QuizShowingFeedback;
        expect(actualState.playedTime, const Duration(seconds: 2));
      },
    );
    test('does not charge a finished reading to the clock', () async {
      // Arrange
      buildBloc(readsByItself: true);
      await start(
        request: QuizRequest(
          profileId: 'profile-1',
          domainId: MultiplicationDomain.domainId,
          mode: QuizMode.timeAttack,
          itemKeys: tableKeys(5),
          questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
          totalTimeLimit: const Duration(seconds: 60),
        ),
      );
      await tick(30);
      speech.finishReading();
      await pumpEventQueue();
      await tick(10);
      // Act
      bloc.add(
        AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
      );
      await pumpEventQueue();
      // Assert: only the second after the reading.
      final QuizShowingFeedback actualState = bloc.state as QuizShowingFeedback;
      expect(actualState.playedTime, const Duration(seconds: 1));
    });
    test(
      'keeps counting the total time of a quiz without the readings',
      () async {
        // Arrange
        buildBloc(readsByItself: true);
        await start(
          request: QuizRequest(
            profileId: 'profile-1',
            domainId: MultiplicationDomain.domainId,
            mode: QuizMode.timeAttack,
            itemKeys: tableKeys(5),
            questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
            totalTimeLimit: const Duration(seconds: 60),
          ),
        );
        // Act
        await tick(100);
        // Assert: 10 seconds of ticks went by during the reading.
        expect(asking().playedTime, Duration.zero);
        // Act
        speech.finishReading();
        await pumpEventQueue();
        await tick(10);
        // Assert
        expect(asking().playedTime, const Duration(seconds: 1));
      },
    );
  });

  group('QuizBloc reading the instruction', () {
    QuizRequest multipleChoiceRequest() {
      return QuizRequest(
        profileId: 'profile-1',
        domainId: MultiplicationDomain.domainId,
        mode: QuizMode.freeTraining,
        itemKeys: tableKeys(5),
        questionTypeIds: const <String>[QuestionTypeIds.multipleChoice],
        baseTimeLimit: QuizTimeLimits.freeTraining,
      );
    }

    test('reads the instruction when its button is tapped', () async {
      // Arrange
      buildBloc();
      await start(request: multipleChoiceRequest());
      // Act
      bloc.add(const ReadAloudToggled(isInstruction: true));
      await pumpEventQueue();
      // Assert
      expect(speech.spoken, <String>['instruction mul:5x1']);
      expect(asking().isReading, isTrue);
      expect(asking().isReadingInstruction, isTrue);
    });
    test('holds the timer while the instruction is read', () async {
      // Arrange
      buildBloc();
      await start(request: multipleChoiceRequest());
      // Act
      bloc.add(const ReadAloudToggled(isInstruction: true));
      await pumpEventQueue();
      await tick(30);
      // Assert
      expect(asking().elapsed, Duration.zero);
    });
    test('stops the instruction when its button is tapped again', () async {
      // Arrange
      buildBloc();
      await start(request: multipleChoiceRequest());
      bloc.add(const ReadAloudToggled(isInstruction: true));
      await pumpEventQueue();
      // Act
      bloc.add(const ReadAloudToggled(isInstruction: true));
      await pumpEventQueue();
      // Assert
      expect(speech.isSpeaking, isFalse);
      expect(asking().isReading, isFalse);
    });
    test('switches to the question when its button is tapped', () async {
      // Arrange
      buildBloc();
      await start(request: multipleChoiceRequest());
      bloc.add(const ReadAloudToggled(isInstruction: true));
      await pumpEventQueue();
      // Act
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Assert
      expect(speech.spoken, <String>[
        'instruction mul:5x1',
        'question mul:5x1',
      ]);
      expect(asking().isReading, isTrue);
      expect(asking().isReadingInstruction, isFalse);
    });
  });

  group('QuizBloc when the engine is slow to stop', () {
    test('restarts the timer at once when the reading is stopped', () async {
      // Arrange
      speech.hangsOnStop = true;
      buildBloc();
      await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Act
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      await tick(10);
      // Assert
      expect(asking().isReading, isFalse);
      expect(asking().elapsed, const Duration(seconds: 1));
      speech.hangsOnStop = false;
      speech.finishReading();
    });
    test(
      'judges an answer at once even if the voice cannot be stopped',
      () async {
        // Arrange
        speech.hangsOnStop = true;
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
        speech.hangsOnStop = false;
        speech.finishReading();
      },
    );
  });

  group('QuizBloc and the readings of other screens', () {
    test('does not cut a reading that replaced its own', () async {
      // Arrange
      buildBloc();
      await start();
      bloc.add(const ReadAloudToggled());
      await pumpEventQueue();
      // Another owner of the voice starts its own reading.
      speech.speak(text: 'un astuce', languageCode: 'fr');
      await pumpEventQueue();
      // Act
      bloc.add(
        AnswerSubmitted(answer: asking().turn.question.expectedAnswer),
      );
      await pumpEventQueue();
      // Assert
      expect(bloc.state, isA<QuizShowingFeedback>());
      expect(speech.isSpeaking, isTrue);
      speech.finishReading();
    });
  });

  group('QuizBloc when a reading starts while an answer is judged', () {
    test('silences the voice once the answer is judged', () async {
      // Arrange
      buildBloc();
      await start();
      final Answer inputAnswer = asking().turn.question.expectedAnswer;
      // Act: the button is tapped in the same breath as the answer.
      bloc
        ..add(AnswerSubmitted(answer: inputAnswer))
        ..add(const ReadAloudToggled());
      await pumpEventQueue();
      // Assert
      expect(bloc.state, isA<QuizShowingFeedback>());
      expect(speech.isSpeaking, isFalse);
    });
  });

  group('QuizBloc when the voice cannot be used', () {
    test(
      'starts the time of the question when there is nothing to say',
      () async {
        // Arrange: a written answer has no instruction to read.
        buildBloc();
        await start();
        // Act
        bloc.add(const ReadAloudToggled(isInstruction: true));
        await pumpEventQueue();
        await tick(10);
        // Assert
        expect(speech.spoken, isEmpty);
        expect(asking().isReading, isFalse);
        expect(asking().elapsed, const Duration(seconds: 1));
      },
    );
    test(
      'starts the quiz without a voice when the voice check fails',
      () async {
        // Arrange
        buildBloc(speechOverride: _UnknownVoiceSpeech());
        // Act
        await start();
        // Assert
        expect(asking().canReadAloud, isFalse);
      },
    );
    test('starts the time of the question when the voice breaks', () async {
      // Arrange
      final List<Object> errors = <Object>[];
      await runZonedGuarded(() async {
        buildBloc(speechOverride: _BrokenSpeech());
        await start();
        // Act
        bloc.add(const ReadAloudToggled());
        await pumpEventQueue();
        await tick(10);
        // Assert
        expect(asking().isReading, isFalse);
        expect(asking().elapsed, const Duration(seconds: 1));
      }, (Object error, StackTrace stackTrace) => errors.add(error));
      expect(errors, isNotEmpty);
    });
  });
}
