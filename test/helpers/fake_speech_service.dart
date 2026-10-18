import 'dart:async';

import 'package:kid_matix/core/services/speech_service.dart';

/// [SpeechService] that makes no sound and keeps what it was asked.
///
/// A reading lasts until the test calls [finishReading] or [stop], so a
/// test can look at what waits for the voice while it "speaks"; with
/// [isInstant] set a reading ends at once.
final class FakeSpeechService implements SpeechService {
  /// Creates the service; [hasVoice] is what [isAvailable] answers.
  FakeSpeechService({this.hasVoice = true, this.isInstant = false});

  /// Whether [isAvailable] answers `true`.
  bool hasVoice;

  /// Whether a reading ends as soon as it starts.
  bool isInstant;

  /// Texts read so far, in order.
  final List<String> spoken = <String>[];

  /// Languages of the readings, in order.
  final List<String> languages = <String>[];

  /// Number of times [stop] was called.
  int stopCount = 0;

  Completer<void>? _reading;

  /// Whether a reading is in progress.
  bool get isSpeaking => _reading != null && !_reading!.isCompleted;

  @override
  Future<bool> isAvailable({required String languageCode}) async => hasVoice;

  @override
  Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    if (!hasVoice) return;
    finishReading();
    spoken.add(text);
    languages.add(languageCode);
    if (isInstant) return;
    final Completer<void> reading = Completer<void>();
    _reading = reading;
    await reading.future;
  }

  @override
  Future<void> stop() async {
    stopCount++;
    finishReading();
  }

  /// Ends the reading in progress, as the voice does when it is done.
  void finishReading() {
    final Completer<void>? reading = _reading;
    if (reading != null && !reading.isCompleted) reading.complete();
  }
}
