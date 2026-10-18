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
    this.contentLanguageCode,
  });

  /// The use cases that speak and stop.
  final QuizReadAloudUseCases useCases;

  /// Language of the voice for the instructions, such as `fr`.
  final String languageCode;

  /// Language the questions of the domain are written in, or `null` to
  /// follow the interface.
  final String? contentLanguageCode;

  /// Language of the voice that reads a question.
  String get questionLanguageCode => contentLanguageCode ?? languageCode;

  /// The sentence of a question; the words come from the localized texts,
  /// which only the presentation layer reads (`QuizLabels.speakQuestion`).
  final String Function(Question question) speakQuestion;

  /// What the player has to do ("Touche la bonne réponse"), or `null` when
  /// the question shows no instruction (`QuizLabels.describeHint`).
  final String? Function(Question question) speakInstruction;
}
