import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_spoken_text.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';

/// [QuizSpokenText] built from the localized texts of the quiz.
///
/// This is where a question type plugs its reading in: add a case to
/// [ofQuestion] that returns its sentence, and to [QuizLabels.describeHint]
/// for its instruction. A type with no case is read like an operation, token
/// by token, with the words of [PromptReading.toSpokenText]; a new prompt
/// token makes that switch (sealed) fail to compile until it has its words.
final class QuizLabelsSpokenText implements QuizSpokenText {
  /// Creates the texts of [labels] for the questions of [domainId].
  const QuizLabelsSpokenText({required this.labels, required this.domainId});

  /// Localized texts of the quiz.
  final QuizLabels labels;

  /// Domain of the questions read.
  final String domainId;

  @override
  String ofQuestion(Question question) {
    final String? drawn = labels.speakQuestion(question);
    if (drawn != null) return drawn;
    final String operation = question.prompt.toSpokenText(labels.l10n);
    return switch (question.questionTypeId) {
      QuestionTypeIds.findOperation =>
        labels.speakFindOperation(question, domainId) ?? operation,
      QuestionTypeIds.trueFalse => labels.l10n.quizSpokenTrueFalse(operation),
      QuestionTypeIds.matchPairs => labels.l10n.quizMatchPairsTitle,
      _ => operation,
    };
  }

  @override
  String? ofInstruction(Question question) => labels.describeHint(question);
}
