/// How a question type collects the answer, as the mastery engine sees it.
enum AnswerNature {
  /// The player picks the answer among choices (multiple choice, true or
  /// false); it cannot move a fact past the middle boxes.
  recognized,

  /// The player writes the answer (typed answer, missing number).
  produced,
}
