import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/services/game_feedback_service.dart';
import 'package:kid_matix/features/setting/data/datasources/audio_sound_player.dart';
import 'package:kid_matix/features/setting/data/datasources/haptic_vibrator.dart';
import 'package:kid_matix/features/setting/domain/services/game_feedback_service_impl.dart';
import 'package:kid_matix/features/setting/domain/services/sound_player.dart';
import 'package:kid_matix/features/setting/domain/services/vibrator.dart';

/// Registers the sounds and vibrations of the game in [sl].
void registerSettingFeature(GetIt sl) {
  sl.registerLazySingleton<SoundPlayer>(AudioSoundPlayer.new);
  sl.registerLazySingleton<Vibrator>(() => const HapticVibrator());
  sl.registerLazySingleton<GameFeedbackService>(
    () => GameFeedbackServiceImpl(
      session: sl(),
      settings: sl(),
      sounds: sl(),
      vibrator: sl(),
    ),
  );
}
