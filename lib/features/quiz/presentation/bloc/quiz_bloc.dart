import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_submission.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_params.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_clock.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_read_aloud.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_request_params.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_reading.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state_run.dart';
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
    required Ticker ticker,
    QuizReadAloud? readAloud,
  }) : super(const QuizPreparing()) {
    _clock = QuizClock(ticker: ticker, addEvent: add);
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
    on<ReadAloudToggled>(
      (ReadAloudToggled event, Emitter<QuizState> emit) =>
          _reading.toggle(emit, isInstruction: event.isInstruction),
    );
    on<AutoReadStarted>(
      (AutoReadStarted event, Emitter<QuizState> emit) => _reading.read(emit),
    );
    on<QuizAbandoned>(_onAbandoned);
  }

  final QuizUseCases _useCases;
  late final QuizClock _clock;
  late final QuizReading _reading;

  Future<void> _onStarted(QuizStarted event, Emitter<QuizState> emit) async {
    emit(const QuizPreparing());
    final QuizRequest request = event.request;
    // The voice check runs while the questions are built.
    final Future<void> foundVoice = _reading.findMode(request);
    final DataState<QuizRun> built = await _useCases.buildQuiz(
      params: request.toBuildParams(
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
    _clock.onTicked(state, emit);
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
    if (!current.run.isNonStop) _clock.stop();
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
    final QuizRun? run = state.playedRun;
    if (run == null) return;
    _clock.stop();
    await _complete(run.stopped(), emit);
  }

  Future<void> _complete(QuizRun run, Emitter<QuizState> emit) async {
    emit(const QuizPreparing());
    emit(await _useCases.finish(run));
  }

  void _onPaused(QuizPaused event, Emitter<QuizState> emit) {
    switch (state) {
      case final QuizAsking current when !current.isPaused:
        _clock.stop();
        if (current.isReading) _reading.silence();
        emit(current.afterReading().copyWith(isPaused: true));
      case QuizShowingFeedback():
        _clock.stop();
      default:
        return;
    }
  }

  Future<void> _onResumed(QuizResumed event, Emitter<QuizState> emit) async {
    switch (state) {
      case final QuizAsking current when current.isPaused:
        if (!current.run.isNonStop) {
          emit(current.copyWith(isPaused: false));
          return _clock.start();
        }
        final QuizRun next = current.run.withoutCurrentTurn();
        if (next.isFinished) return _complete(next, emit);
        _ask(next, emit, current.playedTime);
      case final QuizShowingFeedback current
          when current.submission.run.isNonStop && !_clock.isRunning:
        _clock.start();
      default:
        return;
    }
  }

  Future<void> _onAbandoned(
    QuizAbandoned event,
    Emitter<QuizState> emit,
  ) async {
    _clock.stop();
    _reading.silence();
    final QuizRun? run = state.playedRun;
    if (run != null) await _useCases.abandonSession(params: run);
    emit(const QuizLeft());
  }

  @override
  Future<void> close() async {
    _clock.stop();
    _reading.silence();
    return super.close();
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
    _clock.start();
    if (_reading.readsByItself && !isClosed) add(const AutoReadStarted());
  }
}
