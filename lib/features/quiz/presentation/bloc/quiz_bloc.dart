import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_submission.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_params.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_read_aloud.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_reading.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';

/// Drives a quiz: questions, timer, feedback, end and abandon.
///
/// The timer lives here, fed by the injected [Ticker]: it measures every
/// answer, even without a visible timer, stops while the app is in the
/// background and turns a timeout into a wrong answer. In a non-stop
/// quiz (against the clock or with lives) it also counts the time of the
/// feedback: the next question comes by itself, a new question replaces
/// the one shown when the app comes back; against the clock the quiz
/// ends when the time runs out.
///
/// With a [QuizReadAloud] it also reads the question aloud when the
/// player taps the listen button; a quiz built without one reads nothing.
final class QuizBloc extends Bloc<QuizEvent, QuizState> {
  /// Creates the Bloc; [readAloud] is `null` when nothing can be read.
  QuizBloc({
    required this._useCases,
    required this._ticker,
    QuizReadAloud? readAloud,
  }) : super(const QuizPreparing()) {
    _reading = QuizReading(setup: readAloud, readState: () => state);
    on<QuizStarted>(_onStarted);
    on<TimerTicked>(_onTicked);
    on<AnswerSubmitted>(
      (AnswerSubmitted event, Emitter<QuizState> emit) =>
          _submit(event.answer, emit),
    );
    on<DigitTyped>(_onDigitTyped);
    on<DigitErased>(_onDigitErased);
    on<TypedAnswerValidated>(_onTypedAnswerValidated);
    on<TimeExpired>(
      (TimeExpired event, Emitter<QuizState> emit) => _submit(null, emit),
    );
    on<NextRequested>(_onNext);
    on<ClockRanOut>(_onClockRanOut);
    on<QuizPaused>(_onPaused);
    on<QuizResumed>(_onResumed);
    on<ReadAloudToggled>(_onReadAloudToggled);
    on<AutoReadStarted>(_onAutoReadStarted);
    on<QuizAbandoned>(_onAbandoned);
  }

  /// Time between two ticks of the timer.
  static const Duration tickInterval = Duration(milliseconds: 100);

  /// In a non-stop quiz, how long a right answer shows before the next
  /// question.
  static const Duration rightFeedbackTime = Duration(milliseconds: 600);

  /// In a non-stop quiz, how long a mistake and its right answer show.
  static const Duration wrongFeedbackTime = Duration(milliseconds: 1500);

  final QuizUseCases _useCases;
  final Ticker _ticker;
  late final QuizReading _reading;
  StreamSubscription<int>? _ticks;

  Future<void> _onStarted(QuizStarted event, Emitter<QuizState> emit) async {
    emit(const QuizPreparing());
    final QuizRequest request = event.request;
    // The voice check runs while the questions are built.
    final Future<void> foundVoice = _reading.findMode(request);
    final DataState<QuizRun> built = await _useCases.buildQuiz(
      params: BuildQuizParams(
        profileId: request.profileId,
        domainId: request.domainId,
        mode: request.mode,
        itemKeys: request.itemKeys,
        selection: request.selection,
        questionCount: request.questionCount,
        sourceKey: request.sourceKey,
        followUpItemKeys: request.followUpItemKeys,
        followUpQuestionCount: request.followUpQuestionCount,
        isBossFight: request.isBossFight,
        totalTimeLimit: request.totalTimeLimit,
        lives: request.lives,
        timeSchedule: request.timeSchedule,
        seededDraw: request.seededDraw,
        questionTypeIds: request.questionTypeIds,
        timeLimit: await _useCases.getTimeLimit(params: request),
      ),
    );
    switch (built) {
      case DataSuccess<QuizRun>(:final data):
        await foundVoice;
        _ask(data, emit);
      case DataFailed<QuizRun>(:final exception):
        emit(QuizFailure(errorCode: exception.code));
    }
  }

  void _onTicked(TimerTicked event, Emitter<QuizState> emit) {
    switch (state) {
      // While the voice reads, the time of the question is held: only the
      // reading is timed, in case the player answers before its end.
      case final QuizAsking current when !current.isPaused && current.isReading:
        emit(
          current.copyWith(readingTime: current.readingTime + tickInterval),
        );
      // The time of a question starts when the voice has finished reading
      // it, and stops while the player listens to it again.
      case final QuizAsking current
          when !current.isPaused && !current.isReading:
        final QuizAsking next = current.copyWith(
          elapsed: current.elapsed + tickInterval,
          playedTime: current.playedTime + tickInterval,
        );
        emit(next);
        final Duration? limit = next.run.currentTimeLimit;
        if (_isOutOfTime(next.run, next.playedTime)) {
          add(const ClockRanOut());
        } else if (limit != null &&
            next.elapsed >= limit &&
            current.elapsed < limit) {
          // Once only: in a non-stop quiz the ticks go on while the
          // timeout is judged.
          add(const TimeExpired());
        }
      case final QuizShowingFeedback current:
        _tickFeedback(current, emit);
      default:
        return;
    }
  }

  /// In a non-stop quiz, the feedback counts in the time and leads to
  /// the next question by itself.
  void _tickFeedback(QuizShowingFeedback current, Emitter<QuizState> emit) {
    final QuizShowingFeedback next = current.copyWith(
      playedTime: current.playedTime + tickInterval,
      shownFor: current.shownFor + tickInterval,
    );
    emit(next);
    final Duration shownTime = next.submission.answer.isCorrect
        ? rightFeedbackTime
        : wrongFeedbackTime;
    if (_isOutOfTime(next.submission.run, next.playedTime)) {
      add(const ClockRanOut());
    } else if (next.shownFor >= shownTime) {
      add(const NextRequested());
    }
  }

  static bool _isOutOfTime(QuizRun run, Duration playedTime) {
    final Duration? limit = run.totalTimeLimit;
    return limit != null && playedTime >= limit;
  }

  void _onDigitTyped(DigitTyped event, Emitter<QuizState> emit) {
    final QuizState current = state;
    if (current is QuizAsking) emit(current.withDigit(event.digit));
  }

  void _onDigitErased(DigitErased event, Emitter<QuizState> emit) {
    final QuizState current = state;
    if (current is QuizAsking) emit(current.withoutLastDigit());
  }

  Future<void> _onTypedAnswerValidated(
    TypedAnswerValidated event,
    Emitter<QuizState> emit,
  ) async {
    final QuizState current = state;
    if (current is! QuizAsking || current.typedDigits.isEmpty) return;
    await _submit(NumberAnswer(int.parse(current.typedDigits)), emit);
  }

  Future<void> _submit(Answer? answer, Emitter<QuizState> emit) async {
    final QuizState current = state;
    if (current is! QuizAsking) return;
    if (!current.run.isNonStop) _stopTicker();
    if (current.isReading) _reading.silence();
    final DataState<QuizSubmission> judged = await _useCases.submitAnswer(
      params: SubmitAnswerParams(
        run: current.run,
        answer: answer,
        answerTime: current.answerTime,
      ),
    );
    // Against the clock the time may have run out meanwhile.
    final QuizState latest = state;
    if (latest is! QuizAsking) return;
    emit(switch (judged) {
      DataSuccess<QuizSubmission>(:final data) => QuizShowingFeedback(
        submission: data,
        givenAnswer: answer,
        playedTime: latest.playedTime + current.unwaitedReadingTime,
      ),
      DataFailed<QuizSubmission>(:final exception) => QuizFailure(
        errorCode: exception.code,
      ),
    });
    // A reading started while the answer was judged must not outlive the
    // question.
    _reading.silence();
  }

  Future<void> _onNext(NextRequested event, Emitter<QuizState> emit) async {
    final QuizState current = state;
    if (current is! QuizShowingFeedback) return;
    final QuizRun run = current.submission.run;
    if (!run.isFinished) return _ask(run, emit, current.playedTime);
    await _complete(run, emit);
  }

  Future<void> _onClockRanOut(
    ClockRanOut event,
    Emitter<QuizState> emit,
  ) async {
    final QuizRun? run = _runOf(state);
    if (run == null) return;
    _stopTicker();
    await _complete(run.stopped(), emit);
  }

  Future<void> _complete(QuizRun run, Emitter<QuizState> emit) async {
    emit(const QuizPreparing());
    final DataState<QuizSessionEntity> saved = await _useCases.completeSession(
      params: run,
    );
    emit(switch (saved) {
      DataSuccess<QuizSessionEntity>(:final data) => QuizCompleted(
        session: data,
      ),
      DataFailed<QuizSessionEntity>(:final exception) => QuizFailure(
        errorCode: exception.code,
      ),
    });
  }

  void _onPaused(QuizPaused event, Emitter<QuizState> emit) {
    switch (state) {
      case final QuizAsking current when !current.isPaused:
        _stopTicker();
        if (current.isReading) _reading.silence();
        emit(current.afterReading().copyWith(isPaused: true));
      case QuizShowingFeedback():
        _stopTicker();
      default:
        return;
    }
  }

  Future<void> _onResumed(QuizResumed event, Emitter<QuizState> emit) async {
    switch (state) {
      case final QuizAsking current when current.isPaused:
        if (!current.run.isNonStop) {
          emit(current.copyWith(isPaused: false));
          return _startTicker();
        }
        final QuizRun next = current.run.withoutCurrentTurn();
        if (next.isFinished) return _complete(next, emit);
        _ask(next, emit, current.playedTime);
      case final QuizShowingFeedback current
          when current.submission.run.isNonStop && _ticks == null:
        _startTicker();
      default:
        return;
    }
  }

  Future<void> _onAbandoned(
    QuizAbandoned event,
    Emitter<QuizState> emit,
  ) async {
    _stopTicker();
    _reading.silence();
    final QuizRun? run = _runOf(state);
    if (run != null) await _useCases.abandonSession(params: run);
    emit(const QuizLeft());
  }

  @override
  Future<void> close() async {
    _stopTicker();
    _reading.silence();
    return super.close();
  }

  static QuizRun? _runOf(QuizState state) {
    return switch (state) {
      QuizAsking(:final QuizRun run) => run,
      QuizShowingFeedback(:final QuizSubmission submission) => submission.run,
      _ => null,
    };
  }

  void _ask(
    QuizRun run,
    Emitter<QuizState> emit, [
    Duration playedTime = Duration.zero,
  ]) {
    emit(
      QuizAsking(
        run: run,
        playedTime: playedTime,
        canReadAloud: _reading.canRead,
        isReading: _reading.readsByItself,
      ),
    );
    _startTicker();
    if (_reading.readsByItself && !isClosed) add(const AutoReadStarted());
  }

  Future<void> _onReadAloudToggled(
    ReadAloudToggled event,
    Emitter<QuizState> emit,
  ) {
    return _reading.toggle(emit, isInstruction: event.isInstruction);
  }

  Future<void> _onAutoReadStarted(
    AutoReadStarted event,
    Emitter<QuizState> emit,
  ) {
    return _reading.read(emit);
  }

  void _startTicker() {
    _stopTicker();
    _ticks = _ticker
        .tick(interval: tickInterval)
        .listen((_) => add(const TimerTicked()));
  }

  void _stopTicker() {
    unawaited(_ticks?.cancel());
    _ticks = null;
  }
}
