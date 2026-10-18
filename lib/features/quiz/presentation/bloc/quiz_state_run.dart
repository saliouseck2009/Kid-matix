import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_submission.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';

/// The run behind a state of the quiz.
extension QuizStateRun on QuizState {
  /// The run being played, or `null` when the quiz is not in a question or
  /// its feedback.
  QuizRun? get playedRun {
    return switch (this) {
      QuizAsking(:final QuizRun run) => run,
      QuizShowingFeedback(:final QuizSubmission submission) => submission.run,
      _ => null,
    };
  }
}
