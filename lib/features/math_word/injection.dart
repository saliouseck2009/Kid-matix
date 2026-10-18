import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';
import 'package:kid_matix/features/math_word/data/datasources/audio_pack_loader.dart';
import 'package:kid_matix/features/math_word/data/datasources/audioplayers_word_audio_player.dart';
import 'package:kid_matix/features/math_word/data/datasources/math_word_asset_source.dart';
import 'package:kid_matix/features/math_word/domain/services/math_word_domain.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_service_impl.dart';

/// Registers the math word feature in [sl]: the audio packs and the
/// domain, after the numbers, since the domains are offered in their
/// registration order. It reads its bundled assets once, from [bundle]
/// (the app bundle by default).
Future<void> registerMathWordFeature(GetIt sl, {AssetBundle? bundle}) async {
  final AssetBundle assets = bundle ?? rootBundle;
  sl.registerSingleton<WordAudioService>(
    WordAudioServiceImpl(
      packs: await AudioPackLoader(bundle: assets).load(),
      player: AudioplayersWordAudioPlayer(),
    ),
  );
  sl<DomainRegistry>().register(
    MathWordDomain(catalog: await MathWordAssetSource(bundle: assets).load()),
  );
}
