import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/mastery/data/datasources/item_progress_local_data_source_impl.dart';
import 'package:kid_matix/features/mastery/data/repositories/item_progress_repository_impl.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_service_impl.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_mastery_grid_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/plan_quiz_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/record_answer_use_case.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/usecases/abandon_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/complete_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_time_limit_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:mocktail/mocktail.dart' hide Answer;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../features/mastery/helpers/mastery_fixtures.dart';
import '../features/quiz/helpers/quiz_fixtures.dart';
import '../helpers/test_quiz_pages.dart';

/// The quiz and the mastery engine over one in-memory database: closing
/// the app midway keeps the answers already given.
void main() {
  late AppDatabase appDatabase;
  late TableChangeBus changeBus;
  late MockQuizSessionRepository mockSessions;
  late QuizBloc bloc;

  setUpAll(() {
    sqfliteFfiInit();
    registerQuizFallbacks();
  });

  setUp(() async {
    appDatabase = await openMasteryDatabase();
    changeBus = TableChangeBus();
    mockSessions = MockQuizSessionRepository();
    final (domains, types) = buildMasteryRegistries();
    final StoppedClock clock = StoppedClock(masteryNow);
    final ItemProgressRepositoryImpl progress = ItemProgressRepositoryImpl(
      progress: ItemProgressLocalDataSourceImpl(database: appDatabase),
      clock: clock,
      changeBus: changeBus,
    );
    final MasteryService mastery = MasteryServiceImpl(
      planQuiz: PlanQuizUseCase(
        repository: progress,
        domains: domains,
        questionTypes: types,
        random: DartRandomSource(seed: 4),
      ),
      recordAnswer: RecordAnswerUseCase(
        repository: progress,
        questionTypes: types,
        clock: clock,
      ),
      getGrid: GetMasteryGridUseCase(repository: progress, domains: domains),
    );
    bloc = QuizBloc(
      useCases: QuizUseCases(
        getTimeLimit: const GetTimeLimitUseCase(
          settings: FixedPlayerSettings(),
        ),
        buildQuiz: buildQuizUseCase(mastery: mastery),
        submitAnswer: buildSubmitAnswerUseCase(mastery: mastery),
        completeSession: CompleteSessionUseCase(
          repository: mockSessions,
          clock: clock,
        ),
        abandonSession: AbandonSessionUseCase(
          repository: mockSessions,
          clock: clock,
        ),
      ),
      ticker: const SilentTicker(),
    );
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  Future<void> answerRight() async {
    final Answer expected =
        (bloc.state as QuizAsking).turn.question.expectedAnswer;
    final Future<QuizState> feedback = bloc.stream.firstWhere(
      (QuizState state) => state is QuizShowingFeedback,
    );
    bloc.add(AnswerSubmitted(answer: expected));
    await feedback;
    final Future<QuizState> next = bloc.stream.firstWhere(
      (QuizState state) => state is QuizAsking,
    );
    bloc.add(const NextRequested());
    await next;
  }

  test('keeps the answers given when the app closes midway', () async {
    // Arrange
    final Future<QuizState> started = bloc.stream.firstWhere(
      (QuizState state) => state is QuizAsking,
    );
    bloc.add(
      QuizStarted(
        request: QuizRequest(
          profileId: 'p1',
          domainId: MultiplicationDomain.domainId,
          mode: QuizMode.freeTraining,
          itemKeys: tableKeys(5),
          questionCount: 10,
          questionTypeIds: const <String>[
            QuestionTypeIds.multipleChoice,
            QuestionTypeIds.typedAnswer,
          ],
        ),
      ),
    );
    await started;
    // Act: three answers, then the app is killed without leaving the quiz.
    for (int index = 0; index < 3; index++) {
      await answerRight();
    }
    await bloc.close();
    // Assert
    final List<Map<String, Object?>> actualRows =
        await (await appDatabase.database).query('item_progress');
    final int actualPresentations = actualRows.fold(
      0,
      (int sum, Map<String, Object?> row) =>
          sum + (row['presentation_count']! as int),
    );
    expect(actualPresentations, 3);
    verifyNever(
      () => mockSessions.saveSession(
        session: any(named: 'session'),
        answers: any(named: 'answers'),
      ),
    );
  });
}
