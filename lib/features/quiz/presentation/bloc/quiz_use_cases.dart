import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/usecases/abandon_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/complete_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_time_limit_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';

/// Use cases of the quiz, grouped so `QuizBloc` takes one argument.
final class QuizUseCases {
  /// Groups the use cases.
  const QuizUseCases({
    required this.getTimeLimit,
    required this.buildQuiz,
    required this.submitAnswer,
    required this.completeSession,
    required this.abandonSession,
  });

  /// Time per question for the player.
  final GetTimeLimitUseCase getTimeLimit;

  /// Builds the questions.
  final BuildQuizUseCase buildQuiz;

  /// Judges an answer.
  final SubmitAnswerUseCase submitAnswer;

  /// Saves a finished quiz.
  final CompleteSessionUseCase completeSession;

  /// Keeps the answers of a quiz left early.
  final AbandonSessionUseCase abandonSession;

  /// Saves the finished [run] and returns the state that follows: the
  /// result, or the failure.
  Future<QuizState> finish(QuizRun run) async {
    return switch (await completeSession(params: run)) {
      DataSuccess<QuizSessionEntity>(:final data) => QuizCompleted(
        session: data,
      ),
      DataFailed<QuizSessionEntity>(:final exception) => QuizFailure(
        errorCode: exception.code,
      ),
    };
  }
}
