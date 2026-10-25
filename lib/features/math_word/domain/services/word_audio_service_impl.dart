import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';
import 'package:kid_matix/features/math_word/domain/entities/audio_pack_manifest.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_overrides.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_player.dart';

/// [WordAudioService] over the audio packs bundled with the app, under
/// the recordings a teacher made on this device ([WordAudioOverrides]):
/// those win, the bundled assets never change.
final class WordAudioServiceImpl implements WordAudioService {
  /// Creates the service over [packs], played by [player].
  WordAudioServiceImpl({
    required List<AudioPackManifest> packs,
    required this._player,
    this._overrides = const NoWordAudioOverrides(),
  }) : _packs = <String, AudioPackManifest>{
         for (final AudioPackManifest pack in packs) pack.language: pack,
       };

  /// Folder of the packs inside the bundled assets.
  static const String packsFolder = 'audio';

  final Map<String, AudioPackManifest> _packs;
  final WordAudioPlayer _player;
  final WordAudioOverrides _overrides;

  // The newest sound: only its handle may stop it.
  SpeechReading? _latest;

  @override
  List<String> get languages => List<String>.unmodifiable(<String>{
    for (final AudioPackManifest pack in _packs.values)
      if (pack.wordKeys.isNotEmpty) pack.language,
    ..._overrides.languages,
  });

  @override
  String? get defaultLanguage => _packs.keys.firstOrNull;

  @override
  bool hasAudio({
    required String languageCode,
    required String wordKey,
    WordAudioKind kind = WordAudioKind.explanation,
  }) {
    return _overrides.pathOf(languageCode, wordKey, kind) != null ||
        _packs[languageCode]?.fileOf(wordKey, kind) != null;
  }

  @override
  SpeechReading play({
    required String languageCode,
    required String wordKey,
    WordAudioKind kind = WordAudioKind.explanation,
  }) {
    final String? recorded = _overrides.pathOf(languageCode, wordKey, kind);
    final String? file = _packs[languageCode]?.fileOf(wordKey, kind);
    if (recorded == null && file == null) return SpeechReading.none;
    final SpeechReading reading = SpeechReading(
      recorded != null
          ? _player.playFile(recorded)
          : _player.play('$packsFolder/$languageCode/$file'),
    );
    _latest = reading;
    return reading;
  }

  @override
  Future<void> stop({SpeechReading? reading}) async {
    if (reading != null && reading != _latest) return;
    await _player.stop();
  }
}
