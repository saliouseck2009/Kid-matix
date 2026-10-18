import 'dart:async';

import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';

/// [WordAudioService] that makes no sound: it holds recordings for the
/// words of [recorded] (their explanation, and their example when listed
/// in [withExample]) and keeps what it was asked to play.
final class FakeWordAudioService implements WordAudioService {
  /// Creates the service of the language [language].
  FakeWordAudioService({
    this.language = 'wo',
    this.recorded = const <String>{},
    this.withExample = const <String>{},
    this.isInstant = true,
  });

  /// Code of the only language of the pack.
  final String language;

  /// Keys of the words that have an explanation.
  final Set<String> recorded;

  /// Keys of the words that also have an example.
  final Set<String> withExample;

  /// Whether a sound ends as soon as it starts; otherwise it lasts until
  /// [stop] or [finishSound].
  final bool isInstant;

  /// What was played, as `<language>:<key>:<kind>`, in order.
  final List<String> played = <String>[];

  /// Number of times [stop] was called.
  int stopCount = 0;

  @override
  List<String> get languages => <String>[language];

  @override
  bool hasAudio({
    required String languageCode,
    required String wordKey,
    WordAudioKind kind = WordAudioKind.explanation,
  }) {
    if (languageCode != language) return false;
    return switch (kind) {
      WordAudioKind.explanation => recorded.contains(wordKey),
      WordAudioKind.example => withExample.contains(wordKey),
    };
  }

  @override
  SpeechReading play({
    required String languageCode,
    required String wordKey,
    WordAudioKind kind = WordAudioKind.explanation,
  }) {
    if (!hasAudio(languageCode: languageCode, wordKey: wordKey, kind: kind)) {
      return SpeechReading.none;
    }
    played.add('$languageCode:$wordKey:${kind.name}');
    if (isInstant) return SpeechReading.none;
    final Completer<void> sound = Completer<void>();
    _sound = sound;
    return SpeechReading(sound.future);
  }

  Completer<void>? _sound;

  /// Ends the sound in progress, as when the recording is over.
  void finishSound() {
    final Completer<void>? sound = _sound;
    if (sound != null && !sound.isCompleted) sound.complete();
  }

  @override
  Future<void> stop({SpeechReading? reading}) async {
    stopCount++;
    finishSound();
  }
}
