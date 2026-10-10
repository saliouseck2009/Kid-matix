import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/quiz/domain/repositories/quiz_session_repository.dart';

/// Saves a finished quiz, its answers included, in one transaction.
///
/// Returns the saved session. Fails with a `ValidationException` while
/// questions are left.
class CompleteSessionUseCase
    implements UseCase<DataState<QuizSessionEntity>, QuizRun> {
  /// Creates the use case.
  const CompleteSessionUseCase({
    required this._repository,
    required this._clock,
  });

  final QuizSessionRepository _repository;
  final Clock _clock;

  @override
  Future<DataState<QuizSessionEntity>> call({required QuizRun params}) async {
    if (!params.isFinished) {
      return const DataFailed<QuizSessionEntity>(
        ValidationException(message: 'Questions are left.'),
      );
    }
    final QuizSessionEntity session = QuizSessionEntity.fromRun(
      run: params,
      status: QuizSessionStatus.completed,
      endedAt: _clock.now(),
    );
    final DataState<void> saved = await _repository.saveSession(
      session: session,
      answers: params.answers,
    );
    return switch (saved) {
      DataSuccess<void>() => DataSuccess<QuizSessionEntity>(session),
      DataFailed<void>(:final exception) => DataFailed<QuizSessionEntity>(
        exception,
      ),
    };
  }
}
