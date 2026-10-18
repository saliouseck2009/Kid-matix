import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kid_matix/features/speech/domain/services/text_to_speech_engine.dart';

/// [TextToSpeechEngine] over the `flutter_tts` plugin, which drives the
/// speech synthesis of Android (the engine chosen in the phone's
/// settings, Google's by default) and of iOS.
///
/// Only a voice that is installed and needs no network counts as a voice
/// (on Android; every iOS voice is on the phone), so a reading never
/// depends on a connection. The end of a reading is the plugin's
/// completion, cancel or error event: the plugin's own `speak` future does
/// not complete when a reading is cancelled on iOS.
final class FlutterTtsEngine implements TextToSpeechEngine {
  /// Creates the engine; [tts] and [platform] are replaced in tests.
  FlutterTtsEngine({FlutterTts? tts, TargetPlatform? platform})
    : _tts = tts ?? FlutterTts(),
      _platform = platform ?? defaultTargetPlatform;

  /// Time given to a stopped voice to report that it stopped.
  static const Duration stopWaitTime = Duration(milliseconds: 400);

  /// Voice locales tried, in this order, for each language of the app.
  static const Map<String, List<String>> voiceLocales = <String, List<String>>{
    'fr': <String>['fr-FR', 'fr-CA', 'fr-BE', 'fr-CH'],
    'en': <String>['en-US', 'en-GB', 'en-AU', 'en-IN'],
    'es': <String>['es-ES', 'es-US', 'es-MX'],
  };

  static const String _logName = 'speech';

  final FlutterTts _tts;
  final TargetPlatform _platform;
  final Map<String, String> _chosenLocales = <String, String>{};
  bool _isPrepared = false;
  Completer<void>? _reading;

  @override
  Future<bool> hasVoice({required String languageCode}) async {
    await _prepare();
    return await _findLocale(languageCode) != null;
  }

  @override
  Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    await _prepare();
    final String? locale = await _findLocale(languageCode);
    if (locale == null) return;
    await stop();
    final Completer<void> reading = Completer<void>();
    _reading = reading;
    await _tts.setLanguage(locale);
    final Object? started = await _tts.speak(text);
    if (started != 1) _finish();
    await reading.future;
  }

  @override
  Future<void> stop() async {
    final Completer<void>? reading = _reading;
    await _tts.stop();
    if (reading == null || reading.isCompleted) return;
    // The voice reports its end of its own accord; wait a moment so the
    // report of this reading cannot end the next one.
    await reading.future.timeout(stopWaitTime, onTimeout: _finish);
  }

  Future<void> _prepare() async {
    if (_isPrepared) return;
    _isPrepared = true;
    _tts.setCompletionHandler(_finish);
    _tts.setCancelHandler(_finish);
    _tts.setErrorHandler((Object? message) {
      log('The voice reported an error: $message', name: _logName);
      _finish();
    });
    if (_platform != TargetPlatform.iOS) return;
    // Without this, the silent switch of the iPhone mutes the voice.
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

  /// Ends the reading in progress; a no-op when none is.
  void _finish() {
    final Completer<void>? reading = _reading;
    if (reading != null && !reading.isCompleted) reading.complete();
  }

  Future<String?> _findLocale(String languageCode) async {
    final String? chosen = _chosenLocales[languageCode];
    if (chosen != null) return chosen;
    for (final String locale in voiceLocales[languageCode] ?? <String>[]) {
      if (await _isInstalled(locale)) {
        return _chosenLocales[languageCode] = locale;
      }
    }
    return null;
  }

  Future<bool> _isInstalled(String locale) async {
    final Object? installed = _platform == TargetPlatform.android
        ? await _tts.isLanguageInstalled(locale)
        : await _tts.isLanguageAvailable(locale);
    return installed == true;
  }
}
