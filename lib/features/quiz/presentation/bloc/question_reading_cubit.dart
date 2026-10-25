import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/features/quiz/domain/entities/read_aloud_mode.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_mode_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_params.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/question_reading_state.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_read_aloud_use_cases.dart';

/// The reading aloud of the questions of a screen outside the quiz, such
/// as the placement test: one Cubit per player and domain, with the same
/// use cases as the quiz.
///
/// Like in a quiz, the voice is looked up for the language the questions
/// are spoken in (the domain's content language, else the interface's),
/// the listen button shows only when a voice exists, and each question
/// reads itself when the player turned it on. No timer waits for the
/// voice. Built without use cases it reads nothing.
final class QuestionReadingCubit extends Cubit<QuestionReadingState> {
  /// Creates the Cubit of the player [_profileId]; [_contentLanguageCode]
  /// is the language the domain's questions are written in, or `null` to
  /// follow the interface.
  QuestionReadingCubit({
    required this._useCases,
    required this._profileId,
    this._contentLanguageCode,
  }) : super(const QuestionReadingState());

  final QuizReadAloudUseCases? _useCases;
  final String _profileId;
  final String? _contentLanguageCode;

  String? _text;
  String? _languageCode;
  SpeechReading? _voice;

  /// Shows a new question whose sentence is [text], in an interface
  /// speaking [interfaceLanguageCode]: the previous reading stops, the
  /// voice is looked up when not known, and the question reads itself when
  /// the player asked for it.
  Future<void> show({
    required String text,
    required String interfaceLanguageCode,
  }) async {
    final QuizReadAloudUseCases? cases = _useCases;
    if (cases == null) return;
    _stopVoice();
    if (state.isSpeaking) emit(state.copyWith(isSpeaking: false));
    _text = text;
    final String languageCode = _contentLanguageCode ?? interfaceLanguageCode;
    if (languageCode != _languageCode) {
      _languageCode = languageCode;
      final ReadAloudMode mode = await cases.getMode(
        params: ReadAloudModeParams(
          profileId: _profileId,
          languageCode: languageCode,
        ),
      );
      if (isClosed || _text != text) return;
      emit(state.copyWith(mode: mode, isSpeaking: false));
    }
    if (state.mode == ReadAloudMode.automatic) _speak();
  }

  /// The listen button: reads the question, or stops the reading.
  void toggle() {
    if (state.isSpeaking) {
      _stopVoice();
      emit(state.copyWith(isSpeaking: false));
    } else {
      _speak();
    }
  }

  void _speak() {
    final QuizReadAloudUseCases? cases = _useCases;
    final String? text = _text;
    final String? languageCode = _languageCode;
    if (cases == null || text == null || languageCode == null) return;
    final SpeechReading voice = cases.read(
      params: ReadAloudParams(text: text, languageCode: languageCode),
    );
    _voice = voice;
    emit(state.copyWith(isSpeaking: true));
    unawaited(
      voice.done.whenComplete(() {
        if (!isClosed && identical(_voice, voice)) {
          emit(state.copyWith(isSpeaking: false));
        }
      }),
    );
  }

  void _stopVoice() {
    final SpeechReading? voice = _voice;
    _voice = null;
    if (voice != null) unawaited(_useCases?.stop(params: voice));
  }

  @override
  Future<void> close() {
    _stopVoice();
    return super.close();
  }
}
