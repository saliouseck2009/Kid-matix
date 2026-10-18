import 'dart:async';
import 'dart:developer';

import 'package:kid_matix/core/services/speech_service.dart';
import 'package:kid_matix/features/speech/domain/services/text_to_speech_engine.dart';

/// [SpeechService] over the speech synthesis of the phone.
///
/// Never throws: an engine that fails is logged and the reading does not
/// happen. A reading is also cut after a time proportional to its text,
/// so a voice that forgets to say it has finished can never hold a caller
/// (a quiz timer waiting for the end of a question) for good; an engine
/// that does not say whether it has a voice counts as having none.
final class SpeechServiceImpl implements SpeechService {
  /// Creates the service over [engine].
  const SpeechServiceImpl({required this._engine});

  /// Time allowed to any reading, whatever its text.
  static const Duration baseReadingTime = Duration(seconds: 3);

  /// Time added for each character of the text.
  static const Duration timePerCharacter = Duration(milliseconds: 120);

  /// Time given to the engine to say whether a voice is installed; a quiz
  /// waits for the answer before it starts, so an engine that never
  /// answers counts as having no voice.
  static const Duration availabilityTimeout = Duration(seconds: 2);

  static const String _logName = 'speech';

  final TextToSpeechEngine _engine;

  /// The longest [text] may be read before the voice is cut.
  static Duration readingTimeOf(String text) {
    return baseReadingTime + timePerCharacter * text.length;
  }

  @override
  Future<bool> isAvailable({required String languageCode}) async {
    try {
      return await _engine
          .hasVoice(languageCode: languageCode)
          .timeout(availabilityTimeout, onTimeout: () => false);
    } on Exception catch (error, stackTrace) {
      _logFailure('Voice check failed', error, stackTrace);
      return false;
    }
  }

  @override
  Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    if (text.trim().isEmpty) return;
    try {
      await _engine
          .speak(text: text, languageCode: languageCode)
          .timeout(readingTimeOf(text));
    } on TimeoutException {
      await stop();
    } on Exception catch (error, stackTrace) {
      _logFailure('Reading failed', error, stackTrace);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _engine.stop();
    } on Exception catch (error, stackTrace) {
      _logFailure('Stopping the voice failed', error, stackTrace);
    }
  }

  void _logFailure(String message, Object error, StackTrace stackTrace) {
    log(message, name: _logName, error: error, stackTrace: stackTrace);
  }
}
