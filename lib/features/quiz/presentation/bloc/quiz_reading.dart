import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/read_aloud_mode.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_mode_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_params.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_read_aloud.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';

/// The reading aloud of a quiz, for `QuizBloc`: whether a voice exists,
/// the question or its instruction being read, and the state of the
/// question while the voice speaks.
///
/// The Bloc routes the events; this class says the sentences and keeps
/// `QuizAsking.isReading` true for exactly as long as the voice is
/// speaking, which holds the timer of the question. Built without a setup
/// it reads nothing.
final class QuizReading {
  /// Creates the reading of a quiz; [readState] gives the state of the
  /// Bloc.
  QuizReading({required this._setup, required this._readState});

  final QuizReadAloud? _setup;
  final QuizState Function() _readState;
  ReadAloudMode _mode = ReadAloudMode.unavailable;

  // Identifies the newest reading: the end of an older one, stopped or
  // replaced, must not touch the state of the question that follows.
  int _readingId = 0;

  // The reading of this quiz in progress, to stop it and no other.
  SpeechReading? _voice;

  /// Whether a voice can read the questions, which shows the listen
  /// buttons.
  bool get canRead => _mode != ReadAloudMode.unavailable;

  /// Whether every new question is read by itself.
  bool get readsByItself => _mode == ReadAloudMode.automatic;

  /// Finds how the questions of the quiz of [request] are read.
  Future<void> findMode(QuizRequest request) async {
    final QuizReadAloud? setup = _setup;
    if (setup == null) return;
    _mode = await setup.useCases.getMode(
      params: ReadAloudModeParams(
        profileId: request.profileId,
        languageCode: setup.questionLanguageCode,
      ),
    );
  }

  /// A listen button: reads what it stands for, or stops its reading. A
  /// tap on the other button replaces the reading in progress.
  Future<void> toggle(
    Emitter<QuizState> emit, {
    required bool isInstruction,
  }) async {
    final QuizState current = _readState();
    if (current is! QuizAsking || !current.canReadAloud) return;
    final bool isThisOneReading =
        current.isReading && current.isReadingInstruction == isInstruction;
    if (isThisOneReading) return stop(emit);
    await read(emit, isInstruction: isInstruction);
  }

  /// Says the question being asked, or its instruction, and waits for the
  /// end of the voice.
  Future<void> read(
    Emitter<QuizState> emit, {
    bool isInstruction = false,
  }) async {
    final QuizReadAloud? setup = _setup;
    final QuizState asking = _readState();
    if (setup == null || asking is! QuizAsking) return;
    final Question question = asking.turn.question;
    final String? text = isInstruction
        ? setup.speakInstruction(question)
        : setup.speakQuestion(question);
    if (text == null) {
      // Nothing to say: a question asked as "being read" starts its time.
      if (asking.isReading) emit(asking.afterReading());
      return;
    }
    final int readingId = ++_readingId;
    emit(
      asking.copyWith(isReading: true, isReadingInstruction: isInstruction),
    );
    final SpeechReading voice = setup.useCases.read(
      params: ReadAloudParams(
        text: text,
        languageCode: isInstruction
            ? setup.languageCode
            : setup.questionLanguageCode,
      ),
    );
    _voice = voice;
    try {
      await voice.done;
    } finally {
      // Whatever happened to the voice, the time of the question starts.
      final QuizState latest = _readState();
      if (readingId == _readingId && latest is QuizAsking) {
        emit(latest.afterReading());
      }
    }
  }

  /// Stops the reading in progress and lets the question go on at once;
  /// the voice is stopped behind, since an engine may be slow to answer.
  Future<void> stop(Emitter<QuizState> emit) async {
    _readingId++;
    final QuizState latest = _readState();
    if (latest is QuizAsking && latest.isReading) {
      emit(latest.afterReading());
    }
    _stopVoice();
  }

  /// Stops the voice without waiting for it, for a question that is
  /// answered, left or hidden. Does nothing to the engine when no voice
  /// exists.
  void silence() {
    _readingId++;
    if (canRead) _stopVoice();
  }

  void _stopVoice() {
    final SpeechReading? voice = _voice;
    if (voice != null) unawaited(_setup?.useCases.stop(params: voice));
  }
}
