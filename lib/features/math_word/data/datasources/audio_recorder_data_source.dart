import 'package:record/record.dart';

/// The microphone of the device.
abstract interface class AudioRecorderDataSource {
  /// Whether the app may record; asks the permission the first time.
  Future<bool> requestPermission();

  /// Starts recording to [path].
  Future<void> start(String path);

  /// Stops recording; resolves to the path of the file, or `null`.
  Future<String?> stop();

  /// Stops recording and deletes the file.
  Future<void> cancel();
}

/// [AudioRecorderDataSource] over `record`, in the format of the packs:
/// AAC in `.m4a`, mono, 32 kHz, 48 kbit/s (`tool/process_audio.py`).
final class RecordAudioRecorder implements AudioRecorderDataSource {
  /// Creates the recorder.
  RecordAudioRecorder();

  static const RecordConfig _config = RecordConfig(
    sampleRate: 32000,
    bitRate: 48000,
    numChannels: 1,
  );

  AudioRecorder? _recorder;

  AudioRecorder get _device => _recorder ??= AudioRecorder();

  @override
  Future<bool> requestPermission() => _device.hasPermission();

  @override
  Future<void> start(String path) => _device.start(_config, path: path);

  @override
  Future<String?> stop() => _device.stop();

  @override
  Future<void> cancel() => _device.cancel();
}
