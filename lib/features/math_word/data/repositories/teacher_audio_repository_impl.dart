import 'dart:developer';

import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/teacher_audio_service.dart';
import 'package:kid_matix/features/math_word/data/datasources/audio_recorder_data_source.dart';
import 'package:kid_matix/features/math_word/data/datasources/teacher_audio_store.dart';
import 'package:kid_matix/features/math_word/domain/entities/audio_pack_manifest.dart';

/// [TeacherAudioService] over the microphone and the device store of the
/// teacher's recordings; the bundled packs only tell what they hold.
final class TeacherAudioRepositoryImpl implements TeacherAudioService {
  /// Creates the repository over the bundled [packs].
  TeacherAudioRepositoryImpl({
    required List<AudioPackManifest> packs,
    required this._store,
    required this._recorder,
  }) : _packs = <String, AudioPackManifest>{
         for (final AudioPackManifest pack in packs) pack.language: pack,
       };

  final Map<String, AudioPackManifest> _packs;
  final TeacherAudioStore _store;
  final AudioRecorderDataSource _recorder;

  @override
  List<String> get packLanguages => List<String>.unmodifiable(<String>{
    ..._packs.keys,
    ..._store.languages,
  });

  @override
  bool hasPackAudio({
    required String languageCode,
    required String wordKey,
    required WordAudioKind kind,
  }) {
    return _packs[languageCode]?.fileOf(wordKey, kind) != null;
  }

  @override
  Future<DataState<Set<String>>> readRecordedKeys({
    required String languageCode,
    required WordAudioKind kind,
  }) {
    return _guard(() async => _store.recordedKeys(languageCode, kind));
  }

  @override
  Future<DataState<void>> startRecording() {
    return _guard(() async {
      if (!await _recorder.requestPermission()) {
        throw const PermissionDeniedException(message: 'Microphone refused.');
      }
      await _recorder.start(await _store.recordingPath());
    });
  }

  @override
  Future<DataState<void>> saveRecording({
    required String languageCode,
    required String wordKey,
    required WordAudioKind kind,
  }) {
    return _guard(() async {
      final String? path = await _recorder.stop();
      if (path == null) {
        throw const NotFoundException(message: 'Nothing recorded.');
      }
      await _store.keep(
        language: languageCode,
        wordKey: wordKey,
        kind: kind,
        source: path,
      );
    });
  }

  @override
  Future<DataState<void>> cancelRecording() => _guard(_recorder.cancel);

  @override
  Future<DataState<void>> deleteRecording({
    required String languageCode,
    required String wordKey,
    required WordAudioKind kind,
  }) {
    return _guard(
      () => _store.remove(language: languageCode, wordKey: wordKey, kind: kind),
    );
  }

  @override
  Future<DataState<List<int>>> exportPack({required String languageCode}) {
    return _guard(() => _store.zip(languageCode));
  }

  @override
  Future<DataState<int>> importPack({required List<int> bytes}) {
    return _guard(() => _store.unzip(bytes));
  }

  Future<DataState<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return DataSuccess<T>(await action());
    } on AppException catch (exception) {
      return DataFailed<T>(exception);
    } on Exception catch (error, stackTrace) {
      log(
        'Teacher recording failure',
        name: 'math_word',
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<T>(UnknownException(message: error.toString()));
    }
  }
}
