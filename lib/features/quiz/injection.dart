import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/question_generator.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_session_local_data_source.dart';
import 'package:kid_matix/features/quiz/data/datasources/quiz_session_local_data_source_impl.dart';
import 'package:kid_matix/features/quiz/data/repositories/quiz_session_repository_impl.dart';
import 'package:kid_matix/features/quiz/domain/repositories/quiz_session_repository.dart';
import 'package:kid_matix/features/quiz/domain/usecases/abandon_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/complete_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_use_case.dart';

/// Registers the quiz feature in [sl]; Blocs are never registered.
void registerQuizFeature(GetIt sl) {
  sl.registerLazySingleton<QuizSessionLocalDataSource>(
    () => QuizSessionLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<QuizSessionRepository>(
    () => QuizSessionRepositoryImpl(
      sessions: sl(),
      clock: sl(),
      changeBus: sl(),
    ),
  );
  _registerUseCases(sl);
}

void _registerUseCases(GetIt sl) {
  sl.registerLazySingleton<QuestionGenerator>(QuestionGenerator.new);
  sl.registerLazySingleton<BuildQuizUseCase>(
    () => BuildQuizUseCase(
      domains: sl(),
      generator: sl(),
      random: sl(),
      idGenerator: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<SubmitAnswerUseCase>(
    () => SubmitAnswerUseCase(
      questionTypes: sl(),
      domains: sl(),
      generator: sl(),
      random: sl(),
    ),
  );
  sl.registerLazySingleton<CompleteSessionUseCase>(
    () => CompleteSessionUseCase(repository: sl(), clock: sl()),
  );
  sl.registerLazySingleton<AbandonSessionUseCase>(
    () => AbandonSessionUseCase(repository: sl(), clock: sl()),
  );
}
