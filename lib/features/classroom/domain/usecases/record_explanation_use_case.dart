import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/services/teacher_audio_service.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';
import 'package:kid_matix/features/classroom/domain/entities/teacher_recordings.dart';

/// What the teacher does with the microphone (F31-06): start a
/// recording (the permission is asked the first time, in the teacher
/// area only), keep it for a word, throw it away, listen to what a word
/// plays now, or delete a word's recording so that the pack's comes back.
///
/// One class for the steps of one recording, which always go together.
class RecordExplanationUseCase {
  /// Creates the use case.
  const RecordExplanationUseCase({
    required this._audio,
    required this._words,
  });

  /// Longest recording: it stops and is kept by itself then (a pack
  /// recording lasts 15 s; the microphone is never left on).
  static const Duration maxLength = Duration(seconds: 30);

  final TeacherAudioService _audio;
  final WordAudioService _words;

  /// Plays what the children hear for [target] on this device: the
  /// teacher's recording, else the pack's.
  SpeechReading play(RecordingTarget target) {
    return _words.play(
      languageCode: target.languageCode,
      wordKey: target.wordKey,
      kind: target.kind,
    );
  }

  /// Starts recording; fails with a `PermissionDeniedException` when the
  /// microphone is refused.
  Future<DataState<void>> start() => _audio.startRecording();

  /// Stops and keeps the recording as [target].
  Future<DataState<void>> keep(RecordingTarget target) {
    return _audio.saveRecording(
      languageCode: target.languageCode,
      wordKey: target.wordKey,
      kind: target.kind,
    );
  }

  /// Stops and throws the recording away.
  Future<DataState<void>> cancel() => _audio.cancelRecording();

  /// Deletes the teacher's recording [target].
  Future<DataState<void>> delete(RecordingTarget target) {
    return _audio.deleteRecording(
      languageCode: target.languageCode,
      wordKey: target.wordKey,
      kind: target.kind,
    );
  }
}
