import 'package:kid_matix/core/entities/game_feedback.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/game_feedback_service.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/features/setting/domain/services/sound_player.dart';
import 'package:kid_matix/features/setting/domain/services/vibrator.dart';

/// [GameFeedbackService] following the settings of the active player:
/// sounds and vibrations are turned off separately.
///
/// A right answer plays a sound; a mistake a soft sound and a light
/// vibration; a celebration a tune and a firmer vibration.
final class GameFeedbackServiceImpl implements GameFeedbackService {
  /// Creates the service.
  const GameFeedbackServiceImpl({
    required this._session,
    required this._settings,
    required this._sounds,
    required this._vibrator,
  });

  final ProfileSessionService _session;
  final PlayerSettingsService _settings;
  final SoundPlayer _sounds;
  final Vibrator _vibrator;

  @override
  Future<void> play(GameFeedback feedback) async {
    final String? profileId = _session.activeProfileId;
    if (profileId == null) return;
    final DataState<({bool isSoundOn, bool isVibrationOn})> choices =
        await _settings.readFeedback(profileId: profileId);
    if (choices is! DataSuccess<({bool isSoundOn, bool isVibrationOn})>) {
      return;
    }
    final VibrationStrength? strength = switch (feedback) {
      GameFeedback.rightAnswer => null,
      GameFeedback.wrongAnswer => VibrationStrength.light,
      GameFeedback.celebration => VibrationStrength.medium,
    };
    if (choices.data.isSoundOn) await _sounds.play(feedback);
    if (choices.data.isVibrationOn && strength != null) {
      await _vibrator.vibrate(strength);
    }
  }
}
