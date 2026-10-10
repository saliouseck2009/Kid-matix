import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/usecases/complete_session_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_quiz_pages.dart';

/// The app's real dependency graph, as `main` builds it, over an on-disk
/// ffi database in a folder of the test.
///
/// [start] plays the launch of the app and [stop] its end, so a test can
/// rebuild the app over the same database file. Only the platform parts
/// are replaced: the database factory, the key-value storage and the
/// timer.
abstract final class TestApp {
  /// Starts the app with its databases in [databasesPath] and [storage] as
  /// the phone's key-value storage.
  static Future<void> start({
    required String databasesPath,
    required LocalStorage storage,
  }) async {
    sqfliteFfiInit();
    databaseFactoryOrNull = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(databasesPath);
    await configureDependencies();
    sl.allowReassignment = true;
    sl.registerLazySingleton<LocalStorage>(() => storage);
    sl.registerLazySingleton<Ticker>(() => const SilentTicker());
    sl.allowReassignment = false;
  }

  /// Closes the app: the database file is closed and every dependency
  /// forgotten.
  static Future<void> stop() async {
    await sl<TableChangeBus>().dispose();
    await sl<AppDatabase>().close();
    await sl.reset();
  }

  /// Creates the player [nickname] and makes them the active one.
  static Future<ProfileEntity> createPlayer(String nickname) async {
    final DataState<ProfileEntity> created = await sl<CreateProfileUseCase>()(
      params: CreateProfileParams(
        nickname: nickname,
        avatar: ProfileAvatar.avatar1,
        color: ProfileColor.violet,
      ),
    );
    final ProfileEntity profile = (created as DataSuccess<ProfileEntity>).data;
    await sl<SelectProfileUseCase>()(params: profile.id);
    return profile;
  }

  /// The learning path of [profileId] in the multiplication domain.
  static Future<LearningPathEntity> pathOf(String profileId) async {
    final DataState<LearningPathEntity> path =
        await sl<GetLearningPathUseCase>()(
          params: LearningPathParams(
            profileId: profileId,
            domainId: LearningDomainIds.multiplication,
          ),
        );
    return (path as DataSuccess<LearningPathEntity>).data;
  }

  /// The request of [stage] of the table [unitKey] for [profileId], built
  /// as the map of the path builds it.
  static QuizRequest stageRequest({
    required String profileId,
    required String unitKey,
    required StageKind stage,
  }) {
    final LearningPathPages pages = LearningPathPages(
      useCases: LearningPathUseCases(getLearningPath: sl(), watchChanges: sl()),
      domains: sl(),
    );
    final QuizSpec spec = pages.specOf(
      StageSource(unitKey: unitKey, stage: stage).toKey(),
    )!;
    return QuizRequest.fromSpec(profileId: profileId, spec: spec);
  }

  /// The quiz screen's Bloc with the app's use cases; [completedAt] dates
  /// the end of the sessions instead of the phone's clock.
  static QuizBloc quizBloc({Clock? completedAt}) {
    return QuizBloc(
      useCases: QuizUseCases(
        getTimeLimit: sl(),
        buildQuiz: sl(),
        submitAnswer: sl(),
        completeSession: completedAt == null
            ? sl()
            : CompleteSessionUseCase(repository: sl(), clock: completedAt),
        abandonSession: sl(),
      ),
      ticker: sl(),
    );
  }

  /// Opens the quiz of [request] in [bloc] and waits for its first
  /// question.
  static Future<void> startQuiz(QuizBloc bloc, QuizRequest request) async {
    final Future<QuizState> asking = bloc.stream.firstWhere(
      (QuizState state) => state is QuizAsking,
    );
    bloc.add(QuizStarted(request: request));
    await asking;
  }

  /// Answers the current question right and waits for what comes next:
  /// another question, or the end of the quiz.
  static Future<QuizState> answerRight(QuizBloc bloc) async {
    final Answer expected =
        (bloc.state as QuizAsking).turn.question.expectedAnswer;
    final Future<QuizState> feedback = bloc.stream.firstWhere(
      (QuizState state) => state is QuizShowingFeedback,
    );
    bloc.add(AnswerSubmitted(answer: expected));
    await feedback;
    final Future<QuizState> next = bloc.stream.firstWhere(
      (QuizState state) =>
          state is QuizAsking || state is QuizCompleted || state is QuizFailure,
    );
    bloc.add(const NextRequested());
    return next;
  }

  /// Answers every question of the quiz in [bloc] right and returns its
  /// last state.
  static Future<QuizState> playToEnd(QuizBloc bloc) async {
    QuizState state = bloc.state;
    while (state is QuizAsking) {
      state = await answerRight(bloc);
    }
    return state;
  }
}
