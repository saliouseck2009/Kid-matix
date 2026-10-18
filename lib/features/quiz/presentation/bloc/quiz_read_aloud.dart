import 'package:kid_matix/features/quiz/presentation/bloc/quiz_read_aloud_use_cases.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_spoken_text.dart';

/// What `QuizBloc` needs to read the questions of a quiz aloud.
///
/// A Bloc built without it reads nothing and shows no listen button.
final class QuizReadAloud {
  /// Creates the setup; [languageCode] is the language of the interface.
  const QuizReadAloud({
    required this.useCases,
    required this.languageCode,
    required this.text,
  });

  /// The use cases that speak and stop.
  final QuizReadAloudUseCases useCases;

  /// Language of the voice, such as `fr`.
  final String languageCode;

  /// The sentences to say.
  final QuizSpokenText text;
}
