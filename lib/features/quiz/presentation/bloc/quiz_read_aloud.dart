import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_read_aloud_use_cases.dart';

/// What `QuizBloc` needs to read the questions of a quiz aloud.
///
/// A Bloc built without it reads nothing and shows no listen button.
final class QuizReadAloud {
  /// Creates the setup; [languageCode] is the language of the interface.
  const QuizReadAloud({
    required this.useCases,
    required this.languageCode,
    required this.speakQuestion,
    required this.speakInstruction,
  });

  /// The use cases that speak and stop.
  final QuizReadAloudUseCases useCases;

  /// Language of the voice, such as `fr`.
  final String languageCode;

  /// The sentence of a question; the words come from the localized texts,
  /// which only the presentation layer reads (`QuizLabels.speakQuestion`).
  final String Function(Question question) speakQuestion;

  /// What the player has to do ("Touche la bonne réponse"), or `null` when
  /// the question shows no instruction (`QuizLabels.describeHint`).
  final String? Function(Question question) speakInstruction;
}
