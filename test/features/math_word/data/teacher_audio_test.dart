import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/math_word/data/datasources/audio_pack_zip.dart';
import 'package:kid_matix/features/math_word/data/datasources/audio_recorder_data_source.dart';
import 'package:kid_matix/features/math_word/data/datasources/teacher_audio_store.dart';
import 'package:kid_matix/features/math_word/data/repositories/teacher_audio_repository_impl.dart';
import 'package:kid_matix/features/math_word/domain/entities/audio_pack_manifest.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_player.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_service_impl.dart';

/// The microphone of a test: it writes a few bytes where it is told.
final class _FakeRecorder implements AudioRecorderDataSource {
  bool isAllowed = true;
  String? _path;

  @override
  Future<bool> requestPermission() async => isAllowed;

  @override
  Future<void> start(String path) async {
    _path = path;
    await File(path).writeAsBytes(<int>[1, 2, 3]);
  }

  @override
  Future<String?> stop() async => _path;

  @override
  Future<void> cancel() async => _path = null;
}

final class _FakePlayer implements WordAudioPlayer {
  final List<String> played = <String>[];

  @override
  Future<void> play(String assetPath) async => played.add(assetPath);

  @override
  Future<void> playFile(String path) async => played.add('file:$path');

  @override
  Future<void> stop() async {}
}

final AudioPackManifest _pack = AudioPackManifest(
  language: 'wo',
  files: const <String, Map<WordAudioKind, String>>{
    'ajouter': <WordAudioKind, String>{
      WordAudioKind.explanation: 'wo_ajouter.m4a',
    },
  },
);

void main() {
  late Directory folder;
  late TeacherAudioStore store;
  late _FakeRecorder recorder;
  late TeacherAudioRepositoryImpl teacherAudio;

  setUp(() async {
    folder = Directory.systemTemp.createTempSync('teacher_audio_');
    store = TeacherAudioStore(root: () async => folder);
    await store.load();
    recorder = _FakeRecorder();
    teacherAudio = TeacherAudioRepositoryImpl(
      packs: <AudioPackManifest>[_pack],
      store: store,
      recorder: recorder,
    );
  });

  tearDown(() => folder.deleteSync(recursive: true));

  Future<void> record(String wordKey) async {
    await teacherAudio.startRecording();
    await teacherAudio.saveRecording(
      languageCode: 'wo',
      wordKey: wordKey,
      kind: WordAudioKind.explanation,
    );
  }

  test('a recording replaces the pack on this device only', () async {
    // Arrange
    final _FakePlayer player = _FakePlayer();
    final WordAudioServiceImpl words = WordAudioServiceImpl(
      packs: <AudioPackManifest>[_pack],
      player: player,
      overrides: store,
    );
    // Act
    await record('ajouter');
    await record('il_reste');
    words.play(languageCode: 'wo', wordKey: 'ajouter');
    // Assert
    expect(player.played.single, 'file:${folder.path}/wo/wo_ajouter.m4a');
    expect(words.hasAudio(languageCode: 'wo', wordKey: 'il_reste'), isTrue);
    expect(words.languages, <String>['wo']);
    expect(
      (await teacherAudio.readRecordedKeys(
        languageCode: 'wo',
        kind: WordAudioKind.explanation,
      )),
      isA<DataSuccess<Set<String>>>().having(
        (DataSuccess<Set<String>> s) => s.data,
        'keys',
        <String>{'ajouter', 'il_reste'},
      ),
    );
    expect(File('${folder.path}/wo/manifest.json').existsSync(), isTrue);
  });

  test('deleting a recording brings the pack back', () async {
    // Arrange
    final _FakePlayer player = _FakePlayer();
    final WordAudioServiceImpl words = WordAudioServiceImpl(
      packs: <AudioPackManifest>[_pack],
      player: player,
      overrides: store,
    );
    await record('ajouter');
    // Act
    await teacherAudio.deleteRecording(
      languageCode: 'wo',
      wordKey: 'ajouter',
      kind: WordAudioKind.explanation,
    );
    words.play(languageCode: 'wo', wordKey: 'ajouter');
    // Assert
    expect(player.played.single, 'audio/wo/wo_ajouter.m4a');
  });

  test('without the microphone, nothing is recorded', () async {
    // Arrange
    recorder.isAllowed = false;
    // Act
    final DataState<void> actual = await teacherAudio.startRecording();
    // Assert
    expect(
      (actual as DataFailed<void>).exception.code,
      AppErrorCode.permissionDenied,
    );
  });

  test(
    'exports a pack in the F28 layout that another device imports',
    () async {
      // Arrange
      await record('ajouter');
      await record('en_plus');
      final Directory other = Directory.systemTemp.createTempSync('other_');
      addTearDown(() => other.deleteSync(recursive: true));
      final TeacherAudioStore otherStore = TeacherAudioStore(
        root: () async => other,
      );
      // Act
      final List<int> actualZip = (await teacherAudio.exportPack(
        languageCode: 'wo',
      ) as DataSuccess<List<int>>).data;
      final int actualCount = await otherStore.unzip(actualZip);
      // Assert
      final Archive actualArchive = ZipDecoder().decodeBytes(actualZip);
      expect(
        actualArchive.files.map((ArchiveFile f) => f.name),
        unorderedEquals(<String>[
          'wo/manifest.json',
          'wo/wo_ajouter.m4a',
          'wo/wo_en_plus.m4a',
        ]),
      );
      final Map<String, Object?> actualManifest = jsonDecode(
        utf8.decode(actualArchive.findFile('wo/manifest.json')!.content),
      ) as Map<String, Object?>;
      expect(actualManifest['format'], 'm4a');
      expect(actualCount, 2);
      expect(
        otherStore.pathOf('wo', 'en_plus', WordAudioKind.explanation),
        '${other.path}/wo/wo_en_plus.m4a',
      );
    },
  );

  test('refuses a file that is not a pack, or names unsafe files', () async {
    // Arrange
    final Archive unsafe = Archive()
      ..add(
        ArchiveFile.bytes(
          'wo/manifest.json',
          utf8.encode(
            '{"language": "wo", "words": '
            '{"x": {"explanation": "../../evil.m4a"}}}',
          ),
        ),
      );
    // Act
    final DataState<int> actualJunk = await teacherAudio.importPack(
      bytes: utf8.encode('not a zip'),
    );
    final DataState<int> actualUnsafe = await teacherAudio.importPack(
      bytes: ZipEncoder().encodeBytes(unsafe),
    );
    // Assert
    expect(
      (actualJunk as DataFailed<int>).exception.code,
      AppErrorCode.invalidFile,
    );
    expect(
      (actualUnsafe as DataFailed<int>).exception.code,
      AppErrorCode.invalidFile,
    );
  });

  test('reads the recordings again at the next start', () async {
    // Arrange
    await record('ajouter');
    final TeacherAudioStore restarted = TeacherAudioStore(
      root: () async => folder,
    );
    // Act
    await restarted.load();
    // Assert
    expect(
      restarted.recordedKeys('wo', WordAudioKind.explanation),
      <String>{'ajouter'},
    );
  });

  test('imports a pack all or nothing', () async {
    // Arrange: a sound recording, then one entry the manifest does not
    // name.
    final Archive inputArchive = Archive()
      ..add(
        ArchiveFile.bytes(
          'wo/manifest.json',
          utf8.encode(
            '{"language": "wo", "words": '
            '{"ajouter": {"explanation": "wo_ajouter.m4a"}}}',
          ),
        ),
      )
      ..add(ArchiveFile.bytes('wo/wo_ajouter.m4a', <int>[1, 2]))
      ..add(ArchiveFile.bytes('wo/extra.m4a', <int>[3]));
    // Act
    final DataState<int> actual = await teacherAudio.importPack(
      bytes: ZipEncoder().encodeBytes(inputArchive),
    );
    // Assert
    expect(
      (actual as DataFailed<int>).exception.code,
      AppErrorCode.invalidFile,
    );
    expect(store.recordedKeys('wo', WordAudioKind.explanation), isEmpty);
    expect(File('${folder.path}/wo/wo_ajouter.m4a').existsSync(), isFalse);
  });

  test('refuses a recording over 2 MB', () async {
    // Arrange
    final Archive inputArchive = Archive()
      ..add(
        ArchiveFile.bytes(
          'wo/manifest.json',
          utf8.encode(
            '{"language": "wo", "words": '
            '{"ajouter": {"explanation": "wo_ajouter.m4a"}}}',
          ),
        ),
      )
      ..add(
        ArchiveFile.bytes(
          'wo/wo_ajouter.m4a',
          List<int>.filled(AudioPackZip.maxFileBytes + 1, 0),
        ),
      );
    // Act
    final DataState<int> actual = await teacherAudio.importPack(
      bytes: ZipEncoder().encodeBytes(inputArchive),
    );
    // Assert
    expect(actual, isA<DataFailed<int>>());
    expect(store.recordedKeys('wo', WordAudioKind.explanation), isEmpty);
  });

  test('accepts a language the app does not ship yet', () async {
    // Arrange
    final Archive inputArchive = Archive()
      ..add(
        ArchiveFile.bytes(
          'ff/manifest.json',
          utf8.encode(
            '{"language": "ff", "words": '
            '{"ajouter": {"explanation": "ff_ajouter.m4a"}}}',
          ),
        ),
      )
      ..add(ArchiveFile.bytes('ff/ff_ajouter.m4a', <int>[1, 2]));
    // Act
    final DataState<int> actual = await teacherAudio.importPack(
      bytes: ZipEncoder().encodeBytes(inputArchive),
    );
    // Assert
    expect((actual as DataSuccess<int>).data, 1);
    expect(teacherAudio.packLanguages, <String>['wo', 'ff']);
    expect(Directory('${folder.path}/.import').existsSync(), isFalse);
  });
}
