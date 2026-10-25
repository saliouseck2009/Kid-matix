import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/classroom/domain/entities/teacher_recordings.dart';
import 'package:kid_matix/features/classroom/domain/usecases/audio_pack_file_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_teacher_recordings_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/record_explanation_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_recordings_state.dart';

/// The use cases of the teacher's recordings.
typedef TeacherRecordingUseCases = ({
  GetTeacherRecordingsUseCase get,
  RecordExplanationUseCase record,
  AudioPackFileUseCase packs,
});

/// The teacher records their own explanation of each math word (F31-06),
/// listens to it, deletes it, and carries the recordings as a pack file.
///
/// The microphone is never left on: a recording stops and is kept after
/// [RecordExplanationUseCase.maxLength], and is thrown away when the
/// page closes (back, teacher area locked) or the app goes to the
/// background ([pause]).
final class TeacherRecordingsCubit extends Cubit<TeacherRecordingsState> {
  /// Creates the Cubit; [ticker] counts the seconds recorded.
  TeacherRecordingsCubit({required this._useCases, required this._ticker})
    : super(const TeacherRecordingsState());

  static const Duration _second = Duration(seconds: 1);

  final TeacherRecordingUseCases _useCases;
  final Ticker _ticker;
  StreamSubscription<int>? _clock;

  // Set by pause or close while the microphone is still starting: the
  // start then stops it at once.
  bool _cancelRequested = false;
  bool _isStarting = false;

  /// Reads the words in [languageCode] for [kind].
  Future<void> load({
    String? languageCode,
    WordAudioKind kind = WordAudioKind.explanation,
  }) async {
    final DataState<TeacherRecordings> read = await _useCases.get(
      params: (languageCode: languageCode, kind: kind),
    );
    if (isClosed) return;
    switch (read) {
      case DataSuccess<TeacherRecordings>(:final data):
        emit(state.showing(data));
      case DataFailed<TeacherRecordings>(:final exception):
        emit(state.after(errorCode: exception.code));
    }
  }

  /// Starts recording [wordKey].
  Future<void> start(String wordKey) async {
    if (state.isBusy || state.recordingWordKey != null) return;
    emit(state.busy);
    _cancelRequested = false;
    _isStarting = true;
    final DataState<void> started = await _useCases.record.start();
    _isStarting = false;
    if (isClosed || _cancelRequested) {
      if (started is DataSuccess<void>) await _useCases.record.cancel();
      if (!isClosed) emit(state.recording(null));
      return;
    }
    emit(switch (started) {
      DataSuccess<void>() => state.recording(wordKey),
      DataFailed<void>(:final exception) => state.after(
        errorCode: exception.code,
      ),
    });
    if (started is DataSuccess<void>) {
      _clock = _ticker.tick(interval: _second).listen(_onSecond);
    }
  }

  void _onSecond(int seconds) {
    final String? wordKey = state.recordingWordKey;
    if (isClosed || wordKey == null) return;
    if (seconds >= RecordExplanationUseCase.maxLength.inSeconds) {
      unawaited(keep());
      return;
    }
    emit(state.recording(wordKey, seconds: seconds));
  }

  /// Throws away the recording in progress, if any: the app went to the
  /// background.
  Future<void> pause() {
    if (_isStarting) _cancelRequested = true;
    return cancel();
  }

  /// Stops and keeps the recording in progress.
  Future<void> keep() async {
    final RecordingTarget? target = _targetOf(state.recordingWordKey);
    if (target == null) return;
    await _stopClock();
    emit(state.busy);
    final DataState<void> kept = await _useCases.record.keep(target);
    await _reload(kept, RecordingNotice.saved);
  }

  /// Stops and throws away the recording in progress.
  Future<void> cancel() async {
    if (state.recordingWordKey == null) return;
    await _stopClock();
    await _useCases.record.cancel();
    if (!isClosed) emit(state.recording(null));
  }

  // Not awaited: the recording must stop at once, whatever the ticker.
  Future<void> _stopClock() async {
    final StreamSubscription<int>? clock = _clock;
    _clock = null;
    if (clock != null) unawaited(clock.cancel());
  }

  @override
  Future<void> close() async {
    if (_isStarting) _cancelRequested = true;
    await cancel();
    return super.close();
  }

  /// Deletes the teacher's recording of [wordKey].
  Future<void> delete(String wordKey) async {
    final RecordingTarget? target = _targetOf(wordKey);
    if (target == null || state.isBusy) return;
    emit(state.busy);
    await _reload(await _useCases.record.delete(target), null);
  }

  /// Plays what the children hear for [wordKey].
  void play(String wordKey) {
    final RecordingTarget? target = _targetOf(wordKey);
    if (target != null) _useCases.record.play(target);
  }

  /// Shares the pack of the recordings.
  Future<void> exportPack() async {
    final String? language = state.page?.languageCode;
    if (language == null || state.isBusy) return;
    emit(state.busy);
    final DataState<bool> shared = await _useCases.packs.export(language);
    if (isClosed) return;
    emit(switch (shared) {
      DataSuccess<bool>(data: true) => state.after(
        notice: RecordingNotice.exported,
      ),
      DataSuccess<bool>() => state.after(),
      DataFailed<bool>(:final exception) => state.after(
        errorCode: exception.code,
      ),
    });
  }

  /// Picks a pack file and adds its recordings.
  Future<void> importPack() async {
    if (state.isBusy) return;
    emit(state.busy);
    final DataState<int?> imported = await _useCases.packs.import();
    final int count = imported is DataSuccess<int?> ? imported.data ?? 0 : 0;
    await _reload(
      imported,
      count > 0 ? RecordingNotice.imported : null,
      importedCount: count,
    );
  }

  Future<void> _reload(
    DataState<Object?> outcome,
    RecordingNotice? notice, {
    int importedCount = 0,
  }) async {
    final TeacherRecordings? page = state.page;
    final AppErrorCode? errorCode = switch (outcome) {
      DataFailed<Object?>(:final exception) => exception.code,
      DataSuccess<Object?>() => null,
    };
    await load(
      languageCode: page?.languageCode,
      kind: page?.kind ?? WordAudioKind.explanation,
    );
    if (isClosed) return;
    emit(
      state.after(
        notice: errorCode == null ? notice : null,
        errorCode: errorCode,
        importedCount: importedCount,
      ),
    );
  }

  RecordingTarget? _targetOf(String? wordKey) {
    final TeacherRecordings? page = state.page;
    final String? language = page?.languageCode;
    if (page == null || language == null || wordKey == null) return null;
    return (languageCode: language, wordKey: wordKey, kind: page.kind);
  }
}
