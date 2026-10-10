import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:kid_matix/core/entities/game_feedback.dart';
import 'package:kid_matix/features/setting/domain/services/sound_player.dart';

/// [SoundPlayer] over the bundled sounds of `assets/sounds/`, made by
/// `tool/generate_sounds.py`.
///
/// One player per sound, created at first use, so a sound starts at once
/// and never waits for another; a sound that cannot play is logged.
final class AudioSoundPlayer implements SoundPlayer {
  /// Creates the player.
  AudioSoundPlayer();

  static const String _logName = 'setting';

  final Map<GameFeedback, AudioPlayer> _players = <GameFeedback, AudioPlayer>{};

  @override
  Future<void> play(GameFeedback feedback) async {
    try {
      final AudioPlayer player = _players.putIfAbsent(
        feedback,
        () => AudioPlayer()..setPlayerMode(PlayerMode.lowLatency),
      );
      await player.stop();
      await player.play(AssetSource(_assetOf(feedback)));
    } on Exception catch (error, stackTrace) {
      log(
        'Sound not played',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static String _assetOf(GameFeedback feedback) {
    return switch (feedback) {
      GameFeedback.rightAnswer => 'sounds/right.wav',
      GameFeedback.wrongAnswer => 'sounds/wrong.wav',
      GameFeedback.celebration => 'sounds/celebration.wav',
    };
  }
}
