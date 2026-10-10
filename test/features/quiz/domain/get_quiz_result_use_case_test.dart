import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_quiz_result_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fixed_learning_path_service.dart';
import '../helpers/quiz_fixtures.dart';

QuizResultEntity _result({
  QuizSessionStatus status = QuizSessionStatus.completed,
  String? sourceKey = 'path:mul:5:training',
}) {
  return QuizResultEntity(
    session: QuizSessionEntity(
      id: 's1',
      profileId: 'p1',
      domainId: 'multiplication',
      mode: QuizMode.path,
      status: status,
      startedAt: quizStart,
      duration: const Duration(minutes: 1),
      questionCount: 10,
      correctCount: 9,
      sourceKey: sourceKey,
    ),
    answers: const <QuizAnswerEntity>[],
  );
}

void main() {
  late MockQuizSessionRepository mockRepository;
  late GetQuizResultUseCase useCase;

  setUp(() {
    mockRepository = MockQuizSessionRepository();
    useCase = GetQuizResultUseCase(
      repository: mockRepository,
      learningPath: const FixedLearningPathService(stars: 2),
    );
  });

  void stubResult(DataState<QuizResultEntity> result) {
    when(
      () => mockRepository.getResult(sessionId: any(named: 'sessionId')),
    ).thenAnswer((_) async => result);
  }

  group('GetQuizResultUseCase', () {
    test('adds the stars of a completed stage', () async {
      // Arrange
      stubResult(DataSuccess<QuizResultEntity>(_result()));
      // Act
      final QuizResultEntity actualResult = (await useCase(
        params: 's1',
      )).requireData;
      // Assert
      expect(actualResult.stars, 2);
      expect(actualResult.session.sourceKey, 'path:mul:5:training');
    });
    test('gives no stars to an abandoned quiz or another quiz', () async {
      // Arrange
      stubResult(
        DataSuccess<QuizResultEntity>(
          _result(status: QuizSessionStatus.abandoned),
        ),
      );
      final QuizResultEntity actualAbandoned = (await useCase(
        params: 's1',
      )).requireData;
      stubResult(DataSuccess<QuizResultEntity>(_result(sourceKey: null)));
      // Act
      final QuizResultEntity actualOther = (await useCase(
        params: 's1',
      )).requireData;
      // Assert
      expect(actualAbandoned.stars, isNull);
      expect(actualOther.stars, isNull);
    });
    test('forwards a failure to read the session', () async {
      // Arrange
      stubResult(const DataFailed<QuizResultEntity>(NotFoundException()));
      // Act
      final AppException? actualException = (await useCase(
        params: 's1',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<NotFoundException>());
    });
  });
}
