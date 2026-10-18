import 'package:kid_matix/features/quiz/domain/usecases/get_read_aloud_mode_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/stop_read_aloud_use_case.dart';

/// Use cases of the reading aloud of the quiz, grouped like
/// `QuizUseCases`.
final class QuizReadAloudUseCases {
  /// Groups the use cases.
  const QuizReadAloudUseCases({
    required this.getMode,
    required this.read,
    required this.stop,
  });

  /// Whether a voice exists and whether the player reads by ear.
  final GetReadAloudModeUseCase getMode;

  /// Reads a text and waits for the end of the voice.
  final ReadAloudUseCase read;

  /// Stops the voice.
  final StopReadAloudUseCase stop;
}
