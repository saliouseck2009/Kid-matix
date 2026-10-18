import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/notification_scheduler.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/setting/domain/usecases/reschedule_reminders_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/set_reminder_enabled_use_case.dart';

import '../features/setting/helpers/reminder_fixtures.dart';
import '../helpers/in_memory_local_storage.dart';
import 'helpers/test_app.dart';

/// The daily reminder over the real wiring: a quiz completed by a player
/// of the phone leaves out the reminder of that day, also after a restart.
void main() {
  late Directory databaseFolder;
  late InMemoryLocalStorage phoneStorage;
  late MovableClock clock;

  Future<void> startApp() async {
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: phoneStorage,
    );
    sl.allowReassignment = true;
    sl.registerLazySingleton<Clock>(() => clock);
    sl.allowReassignment = false;
  }

  setUp(() async {
    databaseFolder = await Directory.systemTemp.createTemp('kid_matix_');
    phoneStorage = InMemoryLocalStorage();
    clock = MovableClock(reminderMorning);
    await startApp();
  });

  tearDown(() async {
    await TestApp.stop();
    await databaseFolder.delete(recursive: true);
  });

  test('a completed quiz skips the reminder of today', () async {
    // Arrange: the reminder is on, today 17:00 comes first.
    await sl<SetReminderEnabledUseCase>()(params: true);
    final FakeNotificationScheduler notifications =
        sl<NotificationScheduler>() as FakeNotificationScheduler;
    expect(notifications.scheduled.first, DateTime(2026, 10, 12, 17));
    final ProfileEntity player = await TestApp.createPlayer('Awa');
    final LearningPathEntity path = await TestApp.pathOf(player.id);
    final QuizBloc bloc = TestApp.quizBloc(
      completedAt: MovableClock(DateTime(2026, 10, 12, 11)),
    );
    await TestApp.startQuiz(
      bloc,
      TestApp.stageRequest(
        profileId: player.id,
        unitKey: path.currentTable!.unitKey,
        stage: StageKind.discovery,
      ),
    );
    // Act
    await TestApp.playToEnd(bloc);
    await bloc.close();
    await pumpEventQueue();
    // Assert
    expect(notifications.scheduled.first, DateTime(2026, 10, 13, 17));
    await TestApp.stop();
    clock = MovableClock(DateTime(2026, 10, 12, 15));
    await startApp();
    await sl<RescheduleRemindersUseCase>()();
    final FakeNotificationScheduler relaunched =
        sl<NotificationScheduler>() as FakeNotificationScheduler;
    expect(relaunched.scheduled.first, DateTime(2026, 10, 13, 17));
  });
}
