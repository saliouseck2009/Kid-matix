import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/services/speech_service.dart';
import 'package:kid_matix/features/speech/data/datasources/flutter_tts_engine.dart';
import 'package:kid_matix/features/speech/domain/services/speech_service_impl.dart';
import 'package:kid_matix/features/speech/domain/services/text_to_speech_engine.dart';

/// Registers the reading aloud of the app in [sl].
void registerSpeechFeature(GetIt sl) {
  sl.registerLazySingleton<TextToSpeechEngine>(FlutterTtsEngine.new);
  sl.registerLazySingleton<SpeechService>(
    () => SpeechServiceImpl(engine: sl()),
  );
}
