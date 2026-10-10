import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';

/// The journal of the quiz sessions played on the device.
abstract interface class QuizSessionRepository {
  /// Writes [session] and its [answers] in one transaction; a session is
  /// never changed afterwards.
  Future<DataState<void>> saveSession({
    required QuizSessionEntity session,
    required List<QuizAnswerEntity> answers,
  });
}
