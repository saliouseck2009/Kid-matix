import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/services/speech_service.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_params.dart';

/// Reads a text of the quiz aloud and completes when the voice is done,
/// is stopped, or could not start, so the quiz can hold its timer until
/// then.
///
/// Unlike other use cases it answers at once with the [SpeechReading] handle
/// (not a future of it), so the caller can stop the reading before it ends.
class ReadAloudUseCase {
  /// Creates the use case.
  const ReadAloudUseCase({required this._speech});

  final SpeechService _speech;

  SpeechReading call({required ReadAloudParams params}) {
    return _speech.speak(
      text: params.text,
      languageCode: params.languageCode,
    );
  }
}
