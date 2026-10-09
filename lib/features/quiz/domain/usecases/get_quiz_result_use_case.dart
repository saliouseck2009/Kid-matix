import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/repositories/quiz_session_repository.dart';

/// Reads a saved session and its answers for the results screen.
///
/// Takes the session identifier.
class GetQuizResultUseCase
    implements UseCase<DataState<QuizResultEntity>, String> {
  /// Creates the use case.
  const GetQuizResultUseCase({required this._repository});

  final QuizSessionRepository _repository;

  @override
  Future<DataState<QuizResultEntity>> call({required String params}) {
    return _repository.getResult(sessionId: params);
  }
}
