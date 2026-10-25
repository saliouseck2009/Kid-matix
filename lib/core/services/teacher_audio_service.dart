import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/error/data_state.dart';

/// The teacher's own recordings of the math words (F31-06): recorded from
/// the teacher area, they replace the recording of the audio pack on this
/// device only, and travel as a pack file in the format of the bundled
/// packs.
///
/// Implemented by the math word feature, which owns the audio packs; the
/// bundled assets are never changed.
abstract interface class TeacherAudioService {
  /// Codes of the help languages of the app (`assets/audio/packs.json`),
  /// even those whose pack is still empty, then those that arrived on
  /// this device by pack file only.
  List<String> get packLanguages;

  /// Whether the bundled pack of [languageCode] holds the recording
  /// [kind] of [wordKey].
  bool hasPackAudio({
    required String languageCode,
    required String wordKey,
    required WordAudioKind kind,
  });

  /// The keys of the words the teacher recorded in [languageCode] for
  /// [kind] on this device.
  Future<DataState<Set<String>>> readRecordedKeys({
    required String languageCode,
    required WordAudioKind kind,
  });

  /// Starts recording; the microphone permission is asked the first time.
  /// Fails with a `PermissionDeniedException` when it is refused.
  Future<DataState<void>> startRecording();

  /// Stops recording and keeps it as the recording [kind] of [wordKey] in
  /// [languageCode], in place of the pack's on this device.
  Future<DataState<void>> saveRecording({
    required String languageCode,
    required String wordKey,
    required WordAudioKind kind,
  });

  /// Stops recording and throws it away.
  Future<DataState<void>> cancelRecording();

  /// Deletes the teacher's recording [kind] of [wordKey]: the pack's
  /// comes back.
  Future<DataState<void>> deleteRecording({
    required String languageCode,
    required String wordKey,
    required WordAudioKind kind,
  });

  /// The pack file of the teacher's recordings in [languageCode]: a zip
  /// holding `<language>/manifest.json` and the recordings, as in
  /// `assets/audio/`. Fails with a `NotFoundException` without any.
  Future<DataState<List<int>>> exportPack({required String languageCode});

  /// Adds the recordings of the pack file [bytes] to this device, in
  /// place of the same words; resolves to how many it held. Fails with an
  /// `InvalidFileException` when it is no pack file. The import of packs
  /// by file of F32-01 goes through here.
  Future<DataState<int>> importPack({required List<int> bytes});
}
