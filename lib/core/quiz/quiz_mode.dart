/// How a quiz was started; stored with the session by [name].
///
/// The challenges and the other modes add their value with their lot.
enum QuizMode {
  /// Free training: tables, question count and timer chosen by the player.
  freeTraining,

  /// A stage of the learning path.
  path,
}
