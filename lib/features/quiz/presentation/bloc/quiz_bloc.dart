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
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';

/// Drives a quiz: questions, timer, feedback, end and abandon.
///
/// The timer lives here, fed by the injected [Ticker]: it measures every
/// answer, even without a visible timer, stops while the app is in the
/// background and turns a timeout into a wrong answer.
final class QuizBloc extends Bloc<QuizEvent, QuizState> {
  /// Creates the Bloc.
  QuizBloc({required this._useCases, required this._ticker})
    : super(const QuizPreparing()) {
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
    on<QuizPaused>(_onPaused);
    on<QuizResumed>(_onResumed);
    on<QuizAbandoned>(_onAbandoned);
  }

  /// Time between two ticks of the timer.
  static const Duration tickInterval = Duration(milliseconds: 100);

  final QuizUseCases _useCases;
  final Ticker _ticker;
  StreamSubscription<int>? _ticks;

  Future<void> _onStarted(QuizStarted event, Emitter<QuizState> emit) async {
    emit(const QuizPreparing());
    final QuizRequest request = event.request;
    final DataState<QuizRun> built = await _useCases.buildQuiz(
      params: BuildQuizParams(
        profileId: request.profileId,
        domainId: request.domainId,
        mode: request.mode,
        itemKeys: request.itemKeys,
        selection: request.selection,
        questionCount: request.questionCount,
        sourceKey: request.sourceKey,
        questionTypeIds: request.questionTypeIds,
        timeLimit: await _useCases.getTimeLimit(params: request),
      ),
    );
    switch (built) {
      case DataSuccess<QuizRun>(:final data):
        _ask(data, emit);
      case DataFailed<QuizRun>(:final exception):
        emit(QuizFailure(errorCode: exception.code));
    }
  }

  void _onTicked(TimerTicked event, Emitter<QuizState> emit) {
    final QuizState current = state;
    if (current is! QuizAsking || current.isPaused) return;
    final QuizAsking next = current.copyWith(
      elapsed: current.elapsed + tickInterval,
    );
    emit(next);
    final Duration? limit = next.run.timeLimit;
    if (limit != null && next.elapsed >= limit) add(const TimeExpired());
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
    _stopTicker();
    final DataState<QuizSubmission> judged = await _useCases.submitAnswer(
      params: SubmitAnswerParams(
        run: current.run,
        answer: answer,
        answerTime: current.elapsed,
      ),
    );
    emit(switch (judged) {
      DataSuccess<QuizSubmission>(:final data) => QuizShowingFeedback(
        submission: data,
        givenAnswer: answer,
      ),
      DataFailed<QuizSubmission>(:final exception) => QuizFailure(
        errorCode: exception.code,
      ),
    });
  }

  Future<void> _onNext(NextRequested event, Emitter<QuizState> emit) async {
    final QuizState current = state;
    if (current is! QuizShowingFeedback) return;
    final QuizRun run = current.submission.run;
    if (!run.isFinished) return _ask(run, emit);
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
    final QuizState current = state;
    if (current is! QuizAsking || current.isPaused) return;
    _stopTicker();
    emit(current.copyWith(isPaused: true));
  }

  void _onResumed(QuizResumed event, Emitter<QuizState> emit) {
    final QuizState current = state;
    if (current is! QuizAsking || !current.isPaused) return;
    emit(current.copyWith(isPaused: false));
    _startTicker();
  }

  Future<void> _onAbandoned(
    QuizAbandoned event,
    Emitter<QuizState> emit,
  ) async {
    _stopTicker();
    final QuizRun? run = switch (state) {
      QuizAsking(:final QuizRun run) => run,
      QuizShowingFeedback(:final QuizSubmission submission) => submission.run,
      _ => null,
    };
    if (run != null) await _useCases.abandonSession(params: run);
    emit(const QuizLeft());
  }

  @override
  Future<void> close() async {
    _stopTicker();
    return super.close();
  }

  void _ask(QuizRun run, Emitter<QuizState> emit) {
    emit(QuizAsking(run: run));
    _startTicker();
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
