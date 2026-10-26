import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/services/crash_reporter.dart';
import 'package:kid_matix/core/services/sentence_splitter.dart';
import 'package:kid_matix/core/services/teacher_audio_service.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';
import 'package:kid_matix/core/services/word_card_service.dart';
import 'package:kid_matix/features/math_word/data/datasources/audio_pack_loader.dart';
import 'package:kid_matix/features/math_word/data/datasources/audio_recorder_data_source.dart';
import 'package:kid_matix/features/math_word/data/datasources/teacher_audio_store.dart';
import 'package:kid_matix/features/math_word/data/repositories/teacher_audio_repository_impl.dart';
import 'package:kid_matix/features/math_word/domain/entities/audio_pack_manifest.dart';
import 'package:kid_matix/features/math_word/data/datasources/audioplayers_word_audio_player.dart';
import 'package:kid_matix/features/math_word/data/datasources/math_word_asset_source.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_catalog.dart';
import 'package:kid_matix/features/math_word/domain/services/catalog_sentence_splitter.dart';
import 'package:kid_matix/features/math_word/domain/services/math_word_domain.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_service_impl.dart';
import 'package:kid_matix/features/math_word/domain/services/word_card_service_impl.dart';
import 'package:path_provider/path_provider.dart';

/// Registers the math word feature in [sl]: the audio packs and the
/// domain (left out when its content is unreadable), after the numbers,
/// since the domains are offered in their registration order. It reads its
/// bundled assets once, from [bundle] (the app bundle by default), and the
/// teacher's recordings of the device in the background (F31-06).
Future<void> registerMathWordFeature(GetIt sl, {AssetBundle? bundle}) async {
  final AssetBundle assets = bundle ?? rootBundle;
  final List<AudioPackManifest> packs = await AudioPackLoader(
    bundle: assets,
  ).load();
  final TeacherAudioStore store = TeacherAudioStore(root: _teacherAudioFolder);
  unawaited(store.load());
  sl.registerSingleton<WordAudioService>(
    WordAudioServiceImpl(
      packs: packs,
      player: AudioplayersWordAudioPlayer(),
      overrides: store,
    ),
  );
  sl.registerLazySingleton<TeacherAudioService>(
    () => TeacherAudioRepositoryImpl(
      packs: packs,
      store: store,
      recorder: RecordAudioRecorder(),
    ),
  );
  // A broken content asset must never stop the app from starting: the
  // domain is left out and the error reported.
  try {
    final MathWordCatalog catalog = await MathWordAssetSource(
      bundle: assets,
    ).load();
    sl.registerSingleton<SentenceSplitter>(
      CatalogSentenceSplitter(catalog: catalog),
    );
    sl<DomainRegistry>().register(MathWordDomain(catalog: catalog));
    sl.registerSingleton<WordCardService>(
      WordCardServiceImpl(catalog: catalog),
    );
  } on Object catch (error, stackTrace) {
    if (sl.isRegistered<CrashReporter>()) {
      sl<CrashReporter>().recordError(error, stackTrace);
    }
    // No word cards to print without the content.
    sl.registerSingleton<WordCardService>(
      WordCardServiceImpl(
        catalog: MathWordCatalog(words: const [], statements: const []),
      ),
    );
  }
}

/// The folder of the teacher's recordings, in the app's private storage:
/// under Documents, which the app keeps out of the iCloud backup
/// (AppDelegate.swift); Android backups are off (allowBackup false).
Future<Directory> _teacherAudioFolder() async {
  final Directory documents = await getApplicationDocumentsDirectory();
  return Directory('${documents.path}/teacher_audio');
}
