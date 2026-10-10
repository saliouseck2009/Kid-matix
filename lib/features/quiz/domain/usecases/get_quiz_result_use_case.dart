import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/learning_path_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/quiz/domain/repositories/quiz_session_repository.dart';

/// Reads a saved session and its answers for the results screen, with the
/// stars of a completed stage of the learning path.
///
/// Takes the session identifier.
class GetQuizResultUseCase
    implements UseCase<DataState<QuizResultEntity>, String> {
  /// Creates the use case.
  const GetQuizResultUseCase({
    required this._repository,
    required this._learningPath,
  });

  final QuizSessionRepository _repository;
  final LearningPathService _learningPath;

  @override
  Future<DataState<QuizResultEntity>> call({required String params}) async {
    final DataState<QuizResultEntity> result = await _repository.getResult(
      sessionId: params,
    );
    if (result is! DataSuccess<QuizResultEntity>) return result;
    final QuizSessionEntity session = result.data.session;
    return DataSuccess<QuizResultEntity>(
      QuizResultEntity(
        session: session,
        answers: result.data.answers,
        stars: session.status == QuizSessionStatus.completed
            ? _learningPath.starsFor(
                sourceKey: session.sourceKey,
                correctCount: session.correctCount,
                questionCount: session.questionCount,
              )
            : null,
      ),
    );
  }
}
