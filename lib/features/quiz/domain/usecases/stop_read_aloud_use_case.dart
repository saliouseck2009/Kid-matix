import 'package:kid_matix/core/services/speech_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';

/// Stops the reading in progress, if any.
class StopReadAloudUseCase implements NoParamUseCase<void> {
  /// Creates the use case.
  const StopReadAloudUseCase({required this._speech});

  final SpeechService _speech;

  @override
  Future<void> call() => _speech.stop();
}
