import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/services/speech_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';

/// Stops a reading of the quiz, given the handle the voice returned for it:
/// a reading that was replaced by a newer one is left alone.
class StopReadAloudUseCase implements UseCase<void, SpeechReading> {
  /// Creates the use case.
  const StopReadAloudUseCase({required this._speech});

  final SpeechService _speech;

  @override
  Future<void> call({required SpeechReading params}) {
    return _speech.stop(reading: params);
  }
}
