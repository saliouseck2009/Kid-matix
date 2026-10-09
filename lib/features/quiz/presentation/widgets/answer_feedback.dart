/// How an answer button looks once the answer is judged.
enum AnswerFeedback {
  /// Not judged, or neither the right answer nor the one picked.
  none,

  /// The right answer, in green with a check.
  right,

  /// The wrong answer picked, in red with a cross.
  wrong,
}
