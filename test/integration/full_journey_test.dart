import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_quiz_result_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/reward/domain/entities/session_rewards_entity.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_session_rewards_use_case.dart';

import '../helpers/in_memory_local_storage.dart';
import 'helpers/test_app.dart';

/// The whole journey of a new player over the real wiring and an on-disk
/// database: create a profile, play the first stage of the path, read the
/// results, then find the progress again after a restart.
void main() {
  late Directory databaseFolder;
  late InMemoryLocalStorage phoneStorage;

  setUp(() async {
    databaseFolder = await Directory.systemTemp.createTemp('kid_matix_');
    phoneStorage = InMemoryLocalStorage();
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: phoneStorage,
    );
  });

  tearDown(() async {
    await TestApp.stop();
    await databaseFolder.delete(recursive: true);
  });

  test('keeps the first stage played after a restart', () async {
    // Arrange: a new player opens the path on the Discovery of table 1.
    final ProfileEntity inputPlayer = await TestApp.createPlayer('Awa');
    final LearningPathEntity inputPath = await TestApp.pathOf(inputPlayer.id);
    final TablePathNode inputTable = inputPath.currentTable!;
    expect(inputTable.number, 1);
    expect(inputTable.nextStage!.kind, StageKind.discovery);
    final QuizBloc bloc = TestApp.quizBloc();
    await TestApp.startQuiz(
      bloc,
      TestApp.stageRequest(
        profileId: inputPlayer.id,
        unitKey: inputTable.unitKey,
        stage: StageKind.discovery,
      ),
    );
    // Act: the stage is played to the end and its results are read.
    final QuizState actualEnd = await TestApp.playToEnd(bloc);
    await bloc.close();
    final String sessionId = (actualEnd as QuizCompleted).session.id;
    final QuizResultEntity actualResult = ((await sl<GetQuizResultUseCase>()(
      params: sessionId,
    )) as DataSuccess<QuizResultEntity>).data;
    final SessionRewardsEntity actualRewards =
        ((await sl<GetSessionRewardsUseCase>()(
          params: sessionId,
        )) as DataSuccess<SessionRewardsEntity?>).data!;
    // Act: the app is closed, then opened again over the same file.
    await TestApp.stop();
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: phoneStorage,
    );
    final ProfileSessionService actualSession = sl<ProfileSessionService>();
    await actualSession.restore();
    final ProfileEntity actualPlayer = ((await sl<GetProfileUseCase>()(
      params: inputPlayer.id,
    )) as DataSuccess<ProfileEntity>).data;
    final TablePathNode actualTable = (await TestApp.pathOf(
      inputPlayer.id,
    )).findTable(inputTable.unitKey)!;
    // Assert: the results of the stage.
    const int expectedStars = 3;
    expect(actualResult.session.correctCount, 10);
    expect(actualResult.session.questionCount, 10);
    expect(actualResult.stars, expectedStars);
    expect(actualRewards.xpEarned, greaterThan(0));
    // Assert: the progress found again after the restart.
    expect(actualSession.activeProfileId, inputPlayer.id);
    expect(actualPlayer.totalXp, actualRewards.xpEarned);
    expect(actualTable.stageOf(StageKind.discovery).stars, expectedStars);
    expect(actualTable.stageOf(StageKind.training).isPlayable, isTrue);
    expect(actualTable.status, anyOf(TableStatus.current, TableStatus.done));
  });
}
