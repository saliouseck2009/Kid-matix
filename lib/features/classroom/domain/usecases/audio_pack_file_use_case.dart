import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/teacher_audio_service.dart';
import 'package:kid_matix/features/classroom/domain/repositories/report_share_repository.dart';

/// The pack files of the teacher's recordings (F31-06): exported through
/// the share sheet for another device, imported from the file picker. A
/// pack file is a zip laid out as `assets/audio/`, so it can also become
/// a bundled pack (F32-01).
class AudioPackFileUseCase {
  /// Creates the use case.
  const AudioPackFileUseCase({
    required this._audio,
    required this._files,
    required this._clock,
  });

  /// Media type of a pack file.
  static const String zipType = 'application/zip';

  final TeacherAudioService _audio;
  final ReportShareRepository _files;
  final Clock _clock;

  /// Shares the pack of the recordings in [languageCode]; resolves to
  /// whether it was shared. Fails with a `NotFoundException` without any
  /// recording.
  Future<DataState<bool>> export(String languageCode) async {
    final DataState<List<int>> pack = await _audio.exportPack(
      languageCode: languageCode,
    );
    if (pack case DataFailed<List<int>>(:final exception)) {
      return DataFailed<bool>(exception);
    }
    final String day = _clock.now().toIso8601String().substring(0, 10);
    return _files.share(
      files: <SharedFile>[
        SharedFile(
          name: 'KidMatix-Pack-$languageCode-$day.zip',
          bytes: (pack as DataSuccess<List<int>>).data,
          mimeType: zipType,
        ),
      ],
    );
  }

  /// Picks a pack file and adds its recordings; resolves to how many it
  /// held, or `null` when no file was chosen.
  Future<DataState<int?>> import() async {
    final DataState<List<int>?> picked = await _files.pick();
    return switch (picked) {
      DataFailed<List<int>?>(:final exception) => DataFailed<int?>(exception),
      DataSuccess<List<int>?>(data: null) => const DataSuccess<int?>(null),
      DataSuccess<List<int>?>(:final List<int> data) => switch (await _audio
          .importPack(bytes: data)) {
        DataSuccess<int>(:final data) => DataSuccess<int?>(data),
        DataFailed<int>(:final exception) => DataFailed<int?>(exception),
      },
    };
  }
}
