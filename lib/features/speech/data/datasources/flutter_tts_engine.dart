import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kid_matix/features/speech/data/datasources/offline_voice.dart';
import 'package:kid_matix/features/speech/data/datasources/offline_voices.dart';
import 'package:kid_matix/features/speech/domain/services/text_to_speech_engine.dart';

/// [TextToSpeechEngine] over the `flutter_tts` plugin, which drives the
/// speech synthesis of Android (the engine chosen in the phone's
/// settings, Google's by default) and of iOS.
///
/// Only a voice that is installed and needs no network counts as a voice,
/// and on Android the engine is told which one to use (see
/// [OfflineVoices]), so a reading never depends on a connection and never
/// sends a text away. The end of a reading is the plugin's completion,
/// cancel or error event: the plugin's own `speak` future does not
/// complete when a reading is cancelled on iOS.
///
/// Readings can overlap (a new question while the previous voice still
/// speaks): each one takes a generation number, and a reading that finds a
/// newer one started gives up at once, so only the newest ever speaks and
/// the end of an old utterance can never end the new one.
final class FlutterTtsEngine implements TextToSpeechEngine {
  /// Creates the engine; [tts] and [platform] are replaced in tests.
  FlutterTtsEngine({FlutterTts? tts, TargetPlatform? platform})
    : _tts = tts ?? FlutterTts(),
      _platform = platform ?? defaultTargetPlatform;

  /// Time given to a stopped voice to report that it stopped.
  static const Duration stopWaitTime = Duration(milliseconds: 400);

  static const String _logName = 'speech';

  final FlutterTts _tts;
  final TargetPlatform _platform;
  final Map<String, OfflineVoice> _voices = <String, OfflineVoice>{};
  bool _hasHandlers = false;
  bool _hasAudioCategory = false;
  int _generation = 0;
  Completer<void>? _reading;
  bool _hasStarted = false;

  @override
  Future<bool> hasVoice({required String languageCode}) async {
    _listenToTheVoice();
    return await _findVoice(languageCode) != null;
  }

  @override
  Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    final int id = ++_generation;
    _listenToTheVoice();
    final OfflineVoice? voice = await _findVoice(languageCode);
    if (voice == null || id != _generation) return;
    await _stopReading();
    if (id != _generation) return;
    final Completer<void> reading = Completer<void>();
    _reading = reading;
    _hasStarted = false;
    if (!await _choose(voice) || id != _generation) {
      _finish(reading);
      return;
    }
    await _setAudioCategory();
    if (id != _generation) {
      _finish(reading);
      return;
    }
    final Object? started = await _tts.speak(text);
    if (started != 1) _finish(reading);
    await reading.future;
  }

  @override
  Future<void> stop() {
    _generation++;
    return _stopReading();
  }

  /// Stops the voice and waits a moment for it to say so, so that the
  /// report of this reading cannot end the next one.
  Future<void> _stopReading() async {
    final Completer<void>? reading = _reading;
    await _tts.stop();
    if (reading == null || reading.isCompleted) return;
    await reading.future.timeout(
      stopWaitTime,
      onTimeout: () => _finish(reading),
    );
  }

  void _listenToTheVoice() {
    if (_hasHandlers) return;
    _hasHandlers = true;
    _tts.setStartHandler(() {
      _hasStarted = true;
    });
    // An end that arrives before the utterance started is the end of the
    // one before it.
    _tts.setCompletionHandler(_finishStarted);
    _tts.setCancelHandler(_finishStarted);
    _tts.setErrorHandler((Object? message) {
      log('The voice reported an error: $message', name: _logName);
      _finishStarted();
    });
  }

  void _finishStarted() {
    if (_hasStarted) _finish(_reading);
  }

  /// Ends [reading] if it has not ended.
  void _finish(Completer<void>? reading) {
    if (reading != null && !reading.isCompleted) reading.complete();
  }

  Future<OfflineVoice?> _findVoice(String languageCode) async {
    final OfflineVoice? chosen = _voices[languageCode];
    if (chosen != null) return chosen;
    final OfflineVoice? found = _platform == TargetPlatform.android
        ? OfflineVoices.pick(
            voices: await _androidVoices(),
            languageCode: languageCode,
          )
        : await _findAppleVoice(languageCode);
    if (found != null) _voices[languageCode] = found;
    return found;
  }

  /// The voices of the Android engine. The plugin answers `null` while the
  /// speech service is disconnected, which says nothing about the voices:
  /// throwing keeps that answer from being taken for "no voice".
  Future<Object?> _androidVoices() async {
    final Object? voices = await _tts.getVoices;
    if (voices == null) {
      throw StateError('The speech service did not list its voices');
    }
    return voices;
  }

  Future<OfflineVoice?> _findAppleVoice(String languageCode) async {
    for (final String locale in OfflineVoices.locales[languageCode] ?? []) {
      if (await _tts.isLanguageAvailable(locale) == true) {
        return OfflineVoice(locale: locale);
      }
    }
    return null;
  }

  /// Tells the engine to use [voice]; `false` when it refuses.
  Future<bool> _choose(OfflineVoice voice) async {
    final String? name = voice.name;
    final Object? done = name == null
        ? await _tts.setLanguage(voice.locale)
        : await _tts.setVoice(<String, String>{
            'name': name,
            'locale': voice.locale,
          });
    return done == 1;
  }

  /// On an iPhone, speaks even when the silent switch is on; set just
  /// before the first reading, so a player who never has one keeps the
  /// audio behaviour of the app as it was.
  Future<void> _setAudioCategory() async {
    if (_platform != TargetPlatform.iOS || _hasAudioCategory) return;
    _hasAudioCategory = true;
    try {
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        <IosTextToSpeechAudioCategoryOptions>[
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
      );
    } on Exception catch (error, stackTrace) {
      log(
        'The audio category was not set',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
