import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/router/profile_session_redirect.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/delete_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../features/mastery/helpers/mastery_fixtures.dart';
import '../helpers/in_memory_local_storage.dart';
import 'helpers/test_app.dart';

/// Edge cases of version 1.0 over the real wiring and an on-disk
/// database (F11-04).
void main() {
  late Directory databaseFolder;
  late InMemoryLocalStorage phoneStorage;

  Future<void> startApp() {
    return TestApp.start(
      databasesPath: databaseFolder.path,
      storage: phoneStorage,
    );
  }

  setUp(() async {
    databaseFolder = await Directory.systemTemp.createTemp('kid_matix_');
    phoneStorage = InMemoryLocalStorage();
    await startApp();
  });

  tearDown(() async {
    await TestApp.stop();
    await databaseFolder.delete(recursive: true);
  });

  Future<Database> database() => sl<AppDatabase>().database;

  QuizRequest discoveryOf(ProfileEntity player) {
    return TestApp.stageRequest(
      profileId: player.id,
      unitKey: 'mul:1',
      stage: StageKind.discovery,
    );
  }

  group('nicknames', () {
    test('refuses a nickname equal to another but for its case', () async {
      // Arrange
      await TestApp.createPlayer('Awa');
      // Act
      final DataState<ProfileEntity> actualState =
          await sl<CreateProfileUseCase>()(
            params: const CreateProfileParams(
              nickname: 'awa',
              avatar: ProfileAvatar.avatar1,
              color: ProfileColor.violet,
            ),
          );
      // Assert
      expect(
        (actualState as DataFailed<ProfileEntity>).exception,
        isA<ConflictException>(),
      );
      final List<ProfileEntity> actualProfiles =
          ((await sl<GetProfilesUseCase>()())
                  as DataSuccess<List<ProfileEntity>>)
              .data;
      expect(
        actualProfiles.map((ProfileEntity profile) => profile.nickname),
        <String>['Awa'],
      );
    });
  });

  group('phone date', () {
    Future<StreakEntity> playDiscoveryOn(
      ProfileEntity player,
      DateTime day,
    ) async {
      final QuizBloc bloc = TestApp.quizBloc(completedAt: StoppedClock(day));
      await TestApp.startQuiz(bloc, discoveryOf(player));
      final QuizState end = await TestApp.playToEnd(bloc);
      await bloc.close();
      expect(end, isA<QuizCompleted>());
      return ((await sl<RewardRepository>().getStreak(
        profileId: player.id,
      )) as DataSuccess<StreakEntity>).data;
    }

    test('leaves the streak alone when the date goes back', () async {
      // Arrange
      final ProfileEntity inputPlayer = await TestApp.createPlayer('Awa');
      await playDiscoveryOn(inputPlayer, DateTime(2026, 10, 10, 9));
      final StreakEntity expectedStreak = await playDiscoveryOn(
        inputPlayer,
        DateTime(2026, 10, 11, 9),
      );
      // Act
      final StreakEntity actualStreak = await playDiscoveryOn(
        inputPlayer,
        DateTime(2026, 10, 8, 9),
      );
      // Assert
      expect(expectedStreak.current, 2);
      expect(actualStreak.current, expectedStreak.current);
      expect(actualStreak.best, expectedStreak.best);
      expect(actualStreak.lastPlayedDay, DateTime(2026, 10, 11));
    });
  });

  group('deleting the active player', () {
    Future<void> waitForNobodyPlaying(ProfileSessionService session) async {
      if (session.activeProfileId == null) return;
      final Completer<void> nobody = Completer<void>();
      void listener() {
        if (session.activeProfileId == null && !nobody.isCompleted) {
          nobody.complete();
        }
      }

      session.addListener(listener);
      await nobody.future;
      session.removeListener(listener);
    }

    test('sends the others back to "Qui joue ?"', () async {
      // Arrange
      await TestApp.createPlayer('Lea');
      final ProfileEntity inputPlayer = await TestApp.createPlayer('Awa');
      final ProfileSessionService session = sl<ProfileSessionService>();
      await session.restore();
      expect(session.activeProfileId, inputPlayer.id);
      // Act
      await sl<DeleteProfileUseCase>()(params: inputPlayer.id);
      await waitForNobodyPlaying(session);
      // Assert
      expect(session.hasProfiles, isTrue);
      expect(
        redirectForProfileSession(
          session: session,
          location: AppRoutes.learningPath,
        ),
        AppRoutes.whoIsPlaying,
      );
    });

    test('opens the creation when the last player is deleted', () async {
      // Arrange
      final ProfileEntity inputPlayer = await TestApp.createPlayer('Awa');
      final ProfileSessionService session = sl<ProfileSessionService>();
      await session.restore();
      // Act
      await sl<DeleteProfileUseCase>()(params: inputPlayer.id);
      await waitForNobodyPlaying(session);
      // Assert
      expect(session.hasProfiles, isFalse);
      expect(
        redirectForProfileSession(
          session: session,
          location: AppRoutes.learningPath,
        ),
        AppRoutes.profileCreation,
      );
    });
  });

  group('closing the app in the middle of a quiz', () {
    test('keeps the answers in the mastery, and no session or XP', () async {
      // Arrange
      final ProfileEntity inputPlayer = await TestApp.createPlayer('Awa');
      final QuizBloc bloc = TestApp.quizBloc();
      await TestApp.startQuiz(bloc, discoveryOf(inputPlayer));
      // Act: three answers, then the app is killed and opened again.
      for (int index = 0; index < 3; index++) {
        await TestApp.answerRight(bloc);
      }
      await bloc.close();
      await TestApp.stop();
      await startApp();
      // Assert
      final Database actualDatabase = await database();
      final List<Map<String, Object?>> actualProgress = await actualDatabase
          .query('item_progress');
      final int actualPresentations = actualProgress.fold(
        0,
        (int sum, Map<String, Object?> row) =>
            sum + (row['presentation_count']! as int),
      );
      expect(actualPresentations, 3);
      expect(
        await actualDatabase.query(
          'quiz_session',
          where: 'status = ?',
          whereArgs: <Object>['completed'],
        ),
        isEmpty,
      );
      expect(await actualDatabase.query('session_reward'), isEmpty);
      final ProfileEntity actualPlayer = ((await sl<GetProfileUseCase>()(
        params: inputPlayer.id,
      )) as DataSuccess<ProfileEntity>).data;
      expect(actualPlayer.totalXp, 0);
    });
  });
}
