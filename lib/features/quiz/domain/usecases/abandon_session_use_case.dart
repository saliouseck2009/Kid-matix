import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/quiz/domain/repositories/quiz_session_repository.dart';

/// Keeps the answers of a quiz the player left, without any reward.
///
/// The session is saved as abandoned; a quiz left before the first answer
/// leaves nothing to keep and saves nothing.
class AbandonSessionUseCase implements UseCase<DataState<void>, QuizRun> {
  /// Creates the use case.
  const AbandonSessionUseCase({
    required this._repository,
    required this._clock,
  });

  final QuizSessionRepository _repository;
  final Clock _clock;

  @override
  Future<DataState<void>> call({required QuizRun params}) async {
    if (params.answers.isEmpty) return const DataSuccess<void>(null);
    return _repository.saveSession(
      session: QuizSessionEntity.fromRun(
        run: params,
        status: QuizSessionStatus.abandoned,
        endedAt: _clock.now(),
      ),
      answers: params.answers,
    );
  }
}
