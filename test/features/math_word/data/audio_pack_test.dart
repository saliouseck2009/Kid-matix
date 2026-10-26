import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/features/math_word/data/datasources/audio_pack_loader.dart';
import 'package:kid_matix/features/math_word/domain/entities/audio_pack_manifest.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_player.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_service_impl.dart';

/// Bundle that holds a few text assets.
final class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.texts);

  final Map<String, String> texts;

  @override
  Future<ByteData> load(String key) async {
    final String? text = texts[key];
    if (text == null) throw FlutterError('Unable to load asset: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
  }
}

/// Player that records what it was asked and ends a sound when told.
final class _FakePlayer implements WordAudioPlayer {
  final List<String> played = <String>[];
  int stopCount = 0;

  @override
  Future<void> play(String assetPath) async => played.add(assetPath);

  @override
  Future<void> playFile(String path) async => played.add('file:$path');

  @override
  Future<void> stop() async => stopCount++;
}

const String _manifestJson = '''
{"language": "wo", "format": "m4a", "words": {
  "il_reste": {"explanation": "wo_il_reste.m4a", "example": "wo_il_reste_exemple.m4a"},
  "ajouter": {"explanation": "wo_ajouter.m4a"},
  "vide": {}
}}''';

AudioPackManifest _manifest() {
  return AudioPackManifest.fromJson(
    jsonDecode(_manifestJson) as Map<String, Object?>,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AudioPackManifest', () {
    test('tells the file of each recording of a word', () {
      // Act
      final AudioPackManifest actualManifest = _manifest();
      // Assert
      expect(actualManifest.language, 'wo');
      expect(
        actualManifest.fileOf('il_reste', WordAudioKind.example),
        'wo_il_reste_exemple.m4a',
      );
      expect(
        actualManifest.fileOf('ajouter', WordAudioKind.explanation),
        'wo_ajouter.m4a',
      );
      expect(actualManifest.fileOf('ajouter', WordAudioKind.example), isNull);
      expect(actualManifest.fileOf('vide', WordAudioKind.explanation), isNull);
      expect(
        actualManifest.fileOf('absent', WordAudioKind.explanation),
        isNull,
      );
      expect(actualManifest.wordKeys, <String>['il_reste', 'ajouter']);
    });

    test('is not provisional without the flag', () {
      // Act
      final AudioPackManifest actualManifest = _manifest();
      // Assert
      expect(actualManifest.isProvisional, isFalse);
      expect(actualManifest.toJson().containsKey('provisional'), isFalse);
    });

    test('reads the provisional flag and keeps it when it changes', () {
      // Arrange
      final AudioPackManifest provisional = AudioPackManifest.fromJson(
        <String, Object?>{
          'language': 'wo',
          'provisional': true,
          'words': <String, Object?>{
            'ajouter': <String, Object?>{'explanation': 'wo_ajouter.m4a'},
          },
        },
      );
      // Act
      final AudioPackManifest actualWith = provisional.withFile(
        'il_reste',
        WordAudioKind.explanation,
        'wo_il_reste.m4a',
      );
      final AudioPackManifest actualWithout = provisional.withoutFile(
        'ajouter',
        WordAudioKind.explanation,
      );
      // Assert
      expect(provisional.isProvisional, isTrue);
      expect(actualWith.isProvisional, isTrue);
      expect(actualWithout.isProvisional, isTrue);
      expect(provisional.toJson()['provisional'], isTrue);
    });

    test('treats an explicit false flag as not provisional', () {
      // Act
      final AudioPackManifest actualManifest = AudioPackManifest.fromJson(
        <String, Object?>{
          'language': 'wo',
          'provisional': false,
          'words': <String, Object?>{},
        },
      );
      // Assert
      expect(actualManifest.isProvisional, isFalse);
    });

    test('refuses a provisional flag that is not a boolean', () {
      // Assert
      expect(
        () => AudioPackManifest.fromJson(<String, Object?>{
          'language': 'wo',
          'provisional': 'yes',
          'words': <String, Object?>{},
        }),
        throwsFormatException,
      );
    });

    test('refuses a manifest of the wrong shape', () {
      // Assert
      expect(
        () =>
            AudioPackManifest.fromJson(<String, Object?>{'words': <Object>[]}),
        throwsFormatException,
      );
      expect(
        () => AudioPackManifest.fromJson(<String, Object?>{
          'language': 'wo',
          'words': <String, Object?>{
            'a': <String, Object?>{'explanation': 3},
          },
        }),
        throwsFormatException,
      );
    });
  });

  group('AudioPackLoader', () {
    test('reads every pack of the index, whatever its language', () async {
      // Arrange
      final _FakeBundle bundle = _FakeBundle(<String, String>{
        'assets/audio/packs.json': '{"languages": ["wo", "xx"]}',
        'assets/audio/wo/manifest.json': _manifestJson,
        'assets/audio/xx/manifest.json': '{"language": "xx", "words": {"total": {"explanation": "xx_total.m4a"}}}',
      });
      // Act
      final List<AudioPackManifest> actualPacks = await AudioPackLoader(
        bundle: bundle,
      ).load();
      // Assert
      expect(
        actualPacks.map((AudioPackManifest pack) => pack.language),
        <String>['wo', 'xx'],
      );
    });

    test('skips a broken or missing pack and a missing index', () async {
      // Arrange
      final _FakeBundle broken = _FakeBundle(<String, String>{
        'assets/audio/packs.json': '{"languages": ["wo", "xx", "yy"]}',
        'assets/audio/wo/manifest.json': '{not json',
        'assets/audio/xx/manifest.json': '{"language": "xx", "words": 3}',
      });
      // Act
      final List<AudioPackManifest> actualBroken = await AudioPackLoader(
        bundle: broken,
      ).load();
      final List<AudioPackManifest> actualNoIndex = await AudioPackLoader(
        bundle: _FakeBundle(<String, String>{}),
      ).load();
      // Assert
      expect(actualBroken, isEmpty);
      expect(actualNoIndex, isEmpty);
    });

    test(
      'reads the pack the app ships, empty until the recordings come',
      () async {
        // Act
        final List<AudioPackManifest> actualPacks = await AudioPackLoader(
          bundle: rootBundle,
        ).load();
        // Assert
        expect(actualPacks, isNotEmpty);
      },
    );
  });

  group('WordAudioServiceImpl', () {
    late _FakePlayer player;
    late WordAudioServiceImpl service;

    setUp(() {
      player = _FakePlayer();
      service = WordAudioServiceImpl(
        packs: <AudioPackManifest>[_manifest()],
        player: player,
      );
    });

    test('lists the languages of its packs', () {
      // Assert
      expect(service.languages, <String>['wo']);
      expect(service.defaultLanguage, 'wo');
    });

    test('offers a pack only once it holds a recording', () {
      // Arrange
      final WordAudioServiceImpl actual = WordAudioServiceImpl(
        packs: <AudioPackManifest>[
          AudioPackManifest(language: 'aa', files: const {}),
          _manifest(),
        ],
        player: player,
      );
      // Assert
      expect(actual.languages, <String>['wo']);
      expect(actual.defaultLanguage, 'aa');
      expect(
        WordAudioServiceImpl(
          packs: const <AudioPackManifest>[],
          player: player,
        ).defaultLanguage,
        isNull,
      );
    });

    test('knows which recordings exist', () {
      // Assert
      expect(
        service.hasAudio(languageCode: 'wo', wordKey: 'il_reste'),
        isTrue,
      );
      expect(
        service.hasAudio(
          languageCode: 'wo',
          wordKey: 'ajouter',
          kind: WordAudioKind.example,
        ),
        isFalse,
      );
      expect(service.hasAudio(languageCode: 'wo', wordKey: 'total'), isFalse);
      expect(
        service.hasAudio(languageCode: 'xx', wordKey: 'il_reste'),
        isFalse,
      );
    });

    test(
      'plays the explanation by default and the example on request',
      () async {
        // Act
        await service.play(languageCode: 'wo', wordKey: 'il_reste').done;
        await service
            .play(
              languageCode: 'wo',
              wordKey: 'il_reste',
              kind: WordAudioKind.example,
            )
            .done;
        // Assert
        expect(player.played, <String>[
          'audio/wo/wo_il_reste.m4a',
          'audio/wo/wo_il_reste_exemple.m4a',
        ]);
      },
    );

    test('plays nothing for a missing recording', () async {
      // Act
      await service.play(languageCode: 'wo', wordKey: 'total').done;
      // Assert
      expect(player.played, isEmpty);
    });

    test('stops only the newest sound when given its handle', () async {
      // Arrange
      final SpeechReading first = service.play(
        languageCode: 'wo',
        wordKey: 'il_reste',
      );
      final SpeechReading second = service.play(
        languageCode: 'wo',
        wordKey: 'ajouter',
      );
      // Act
      await service.stop(reading: first);
      final int stoppedByOld = player.stopCount;
      await service.stop(reading: second);
      await service.stop();
      // Assert
      expect(stoppedByOld, 0);
      expect(player.stopCount, 2);
    });
  });

  group('Audio packs on disk', () {
    final Map<String, Object?> index = jsonDecode(
      File('assets/audio/packs.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final Set<String> wordKeys = <String>{
      for (final Object? word
          in (jsonDecode(
                File('assets/math_words/math_words.json').readAsStringSync(),
              ) as Map<String, Object?>)['words']!
              as List<Object?>)
        (word! as Map<String, Object?>)['key']! as String,
    };
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    final String problems = File(
      'docs/product/problems.md',
    ).readAsStringSync();

    for (final Object? language in index['languages']! as List<Object?>) {
      test('the pack $language is declared, named and complete', () {
        // Arrange
        final Directory folder = Directory('assets/audio/$language');
        final AudioPackManifest manifest = AudioPackManifest.fromJson(
          jsonDecode(File('${folder.path}/manifest.json').readAsStringSync())
              as Map<String, Object?>,
        );
        // Assert
        expect(manifest.language, language);
        expect(pubspec, contains('- assets/audio/$language/'));
        for (final String key in manifest.wordKeys) {
          // A problem statement is named problem_<key> in its table.
          expect(
            wordKeys.contains(key) ||
                (key.startsWith('problem_') &&
                    problems.contains('${language}_$key.m4a')),
            isTrue,
            reason: key,
          );
          for (final WordAudioKind kind in WordAudioKind.values) {
            final String? file = manifest.fileOf(key, kind);
            if (file == null) continue;
            expect(
              File('${folder.path}/$file').existsSync(),
              isTrue,
              reason: file,
            );
            final String suffix = kind == WordAudioKind.example
                ? '_exemple'
                : '';
            expect(file, '${language}_$key$suffix.m4a');
          }
        }
      });
    }
  });
}
