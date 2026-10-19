import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_player.dart';

/// [WordAudioPlayer] over `audioplayers`, the player the sounds of the app
/// already use.
///
/// One player for the recordings: a new sound stops the previous one, and
/// [play] completes when the sound ends, is stopped or fails.
final class AudioplayersWordAudioPlayer implements WordAudioPlayer {
  /// Creates the player.
  AudioplayersWordAudioPlayer();

  static const String _logName = 'math_word';

  // A recording lasts 15 seconds at most; the wait gives up long after.
  static const Duration _giveUp = Duration(minutes: 2);

  AudioPlayer? _player;
  Completer<void>? _pending;

  @override
  Future<void> play(String assetPath) async {
    _finishPending();
    final Completer<void> done = Completer<void>();
    _pending = done;
    StreamSubscription<void>? subscription;
    try {
      final AudioPlayer player = _player ??= AudioPlayer();
      await player.stop();
      subscription = player.onPlayerComplete.listen((_) => _finish(done));
      await player.play(AssetSource(assetPath));
      await done.future.timeout(_giveUp, onTimeout: () {});
    } on Exception catch (error, stackTrace) {
      log(
        'Recording not played',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      await subscription?.cancel();
      _finish(done);
    }
  }

  @override
  Future<void> stop() async {
    _finishPending();
    try {
      await _player?.stop();
    } on Exception catch (error, stackTrace) {
      log(
        'Recording not stopped',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _finishPending() {
    final Completer<void>? pending = _pending;
    if (pending != null) _finish(pending);
  }

  void _finish(Completer<void> done) {
    if (!done.isCompleted) done.complete();
    if (identical(_pending, done)) _pending = null;
  }
}
