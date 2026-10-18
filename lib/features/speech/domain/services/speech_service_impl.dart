import 'dart:async';
import 'dart:developer';

import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/services/speech_service.dart';
import 'package:kid_matix/features/speech/domain/services/text_to_speech_engine.dart';

/// [SpeechService] over the speech synthesis of the phone.
///
/// Never throws: an engine that fails is logged and the reading does not
/// happen. A reading is also cut after a time proportional to its text,
/// so a voice that forgets to say it has finished can never hold a caller
/// (a quiz timer waiting for the end of a question) for good; an engine
/// that does not say whether it has a voice counts as having none, and one
/// that never answers a stop is left behind after [stopTimeout].
final class SpeechServiceImpl implements SpeechService {
  /// Creates the service over [engine].
  SpeechServiceImpl({required this._engine});

  /// Time allowed to any reading, whatever its text.
  static const Duration baseReadingTime = Duration(seconds: 3);

  /// Time added for each character of the text.
  static const Duration timePerCharacter = Duration(milliseconds: 120);

  /// Time given to the engine to say whether a voice is installed; a quiz
  /// waits for the answer before it starts, so an engine that never
  /// answers counts as having no voice.
  static const Duration availabilityTimeout = Duration(seconds: 2);

  /// Time given to the engine to stop the voice; a plugin that queues its
  /// calls while the engine of the phone starts, or restarts, may never
  /// answer, and nothing may wait for it.
  static const Duration stopTimeout = Duration(seconds: 1);

  static const String _logName = 'speech';

  final TextToSpeechEngine _engine;
  final Set<String> _hasNoVoice = <String>{};

  // Number of the newest reading, and of each one by its future, so that a
  // reading which was replaced can neither cut nor be cut by the others.
  int _latestId = 0;
  final Expando<int> _ids = Expando<int>('speech reading');

  /// The longest [text] may be read before the voice is cut.
  static Duration readingTimeOf(String text) {
    return baseReadingTime + timePerCharacter * text.length;
  }

  @override
  Future<bool> isAvailable({required String languageCode}) async {
    if (_hasNoVoice.contains(languageCode)) return false;
    try {
      final bool hasVoice = await _engine
          .hasVoice(languageCode: languageCode)
          .timeout(availabilityTimeout);
      // An engine that answered "none" is asked once for the session: a
      // phone without a voice does not get one while the app runs. A slow
      // or broken engine is asked again next time.
      if (!hasVoice) _hasNoVoice.add(languageCode);
      return hasVoice;
    } on TimeoutException {
      return false;
    } on Exception catch (error, stackTrace) {
      _logFailure('Voice check failed', error, stackTrace);
      return false;
    }
  }

  @override
  SpeechReading speak({required String text, required String languageCode}) {
    final int id = ++_latestId;
    if (text.trim().isEmpty) {
      // Nothing to say, but the reading in progress is replaced all the same.
      unawaited(_stopEngine());
      return SpeechReading.none;
    }
    final SpeechReading reading = SpeechReading(
      _read(id, text, languageCode),
    );
    _ids[reading] = id;
    return reading;
  }

  Future<void> _read(int id, String text, String languageCode) async {
    try {
      await _engine
          .speak(text: text, languageCode: languageCode)
          .timeout(readingTimeOf(text));
    } on TimeoutException {
      // The voice is cut without waiting for the engine to say so, unless
      // a newer reading has taken its place by now.
      if (id == _latestId) unawaited(_stopEngine());
    } on Exception catch (error, stackTrace) {
      _logFailure('Reading failed', error, stackTrace);
    }
  }

  @override
  Future<void> stop({SpeechReading? reading}) async {
    if (reading != null && _ids[reading] != _latestId) return;
    await _stopEngine();
  }

  Future<void> _stopEngine() async {
    try {
      await _engine.stop().timeout(stopTimeout, onTimeout: () {});
    } on Exception catch (error, stackTrace) {
      _logFailure('Stopping the voice failed', error, stackTrace);
    }
  }

  void _logFailure(String message, Object error, StackTrace stackTrace) {
    log(message, name: _logName, error: error, stackTrace: stackTrace);
  }
}
