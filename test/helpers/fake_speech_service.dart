import 'dart:async';

import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/services/speech_service.dart';

/// [SpeechService] that makes no sound and keeps what it was asked.
///
/// A reading lasts until the test calls [finishReading] or [stop], so a
/// test can look at what waits for the voice while it "speaks"; with
/// [isInstant] set a reading ends at once, and with [ignoresStop] set a
/// stop leaves the reading going until the next one replaces it.
final class FakeSpeechService implements SpeechService {
  /// Creates the service; [hasVoice] is what [isAvailable] answers.
  FakeSpeechService({
    this.hasVoice = true,
    this.isInstant = false,
    this.ignoresStop = false,
    this.hangsOnStop = false,
  });

  /// Whether [isAvailable] answers `true`.
  bool hasVoice;

  /// Whether a reading ends as soon as it starts.
  bool isInstant;

  /// Whether [stop] is counted but does not end the reading in progress.
  bool ignoresStop;

  /// Whether [stop] never answers, as a plugin does that queues its calls
  /// while the engine of the phone restarts; the reading is not ended.
  bool hangsOnStop;

  /// Texts read so far, in order.
  final List<String> spoken = <String>[];

  /// Languages of the readings, in order.
  final List<String> languages = <String>[];

  /// Number of times [stop] was called.
  int stopCount = 0;

  Completer<void>? _reading;
  SpeechReading? _latest;

  /// Whether a reading is in progress.
  bool get isSpeaking => _reading != null && !_reading!.isCompleted;

  @override
  Future<bool> isAvailable({required String languageCode}) async => hasVoice;

  @override
  SpeechReading speak({required String text, required String languageCode}) {
    if (!hasVoice) return SpeechReading.none;
    finishReading();
    spoken.add(text);
    languages.add(languageCode);
    final SpeechReading reading = SpeechReading(_run());
    _latest = reading;
    return reading;
  }

  Future<void> _run() async {
    if (isInstant) return;
    final Completer<void> reading = Completer<void>();
    _reading = reading;
    await reading.future;
  }

  @override
  Future<void> stop({SpeechReading? reading}) async {
    if (reading != null && !identical(reading, _latest)) return;
    stopCount++;
    if (hangsOnStop) await Completer<void>().future;
    if (!ignoresStop) finishReading();
  }

  /// Ends the reading in progress, as the voice does when it is done.
  void finishReading() {
    final Completer<void>? reading = _reading;
    if (reading != null && !reading.isCompleted) reading.complete();
  }
}
