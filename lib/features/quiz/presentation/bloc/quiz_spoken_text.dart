import 'package:kid_matix/core/quiz/question.dart';

/// What the quiz says aloud, as sentences of the language of the
/// interface.
///
/// The Bloc only asks for the text of a question; the words come from the
/// localized texts, which only the presentation layer can read.
abstract interface class QuizSpokenText {
  /// The question as a sentence, such as "5 fois 7 égale combien".
  String ofQuestion(Question question);

  /// What the player has to do ("Touche la bonne réponse"), or `null`
  /// when the question shows no instruction.
  String? ofInstruction(Question question);
}
