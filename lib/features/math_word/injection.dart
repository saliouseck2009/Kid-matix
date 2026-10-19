import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';
import 'package:kid_matix/features/math_word/data/datasources/audio_pack_loader.dart';
import 'package:kid_matix/features/math_word/data/datasources/audioplayers_word_audio_player.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_service_impl.dart';

/// Registers the math word feature in [sl]. It reads its bundled assets
/// once, from [bundle] (the app bundle by default).
Future<void> registerMathWordFeature(GetIt sl, {AssetBundle? bundle}) async {
  final AssetBundle assets = bundle ?? rootBundle;
  sl.registerSingleton<WordAudioService>(
    WordAudioServiceImpl(
      packs: await AudioPackLoader(bundle: assets).load(),
      player: AudioplayersWordAudioPlayer(),
    ),
  );
}
