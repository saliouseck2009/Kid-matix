import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/services/game_feedback_service.dart';
import 'package:kid_matix/core/services/notification_scheduler.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/setting/data/datasources/audio_sound_player.dart';
import 'package:kid_matix/features/setting/data/datasources/haptic_vibrator.dart';
import 'package:kid_matix/features/setting/data/datasources/local_notification_scheduler.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_local_data_source.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_local_data_source_impl.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_notification_texts.dart';
import 'package:kid_matix/features/setting/data/repositories/reminder_repository_impl.dart';
import 'package:kid_matix/features/setting/data/repositories/reminder_session_hook.dart';
import 'package:kid_matix/features/setting/domain/repositories/reminder_repository.dart';
import 'package:kid_matix/features/setting/domain/services/game_feedback_service_impl.dart';
import 'package:kid_matix/features/setting/domain/services/reminder_scheduler.dart';
import 'package:kid_matix/features/setting/domain/services/sound_player.dart';
import 'package:kid_matix/features/setting/domain/services/vibrator.dart';
import 'package:kid_matix/features/setting/domain/usecases/get_reminder_settings_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/record_finished_session_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/reschedule_reminders_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/set_reminder_enabled_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/set_reminder_time_use_case.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Registers the sounds and vibrations of the game and the daily reminder
/// in [sl].
void registerSettingFeature(GetIt sl) {
  _registerGameFeedback(sl);
  _registerReminder(sl);
}

void _registerGameFeedback(GetIt sl) {
  sl.registerLazySingleton<SoundPlayer>(AudioSoundPlayer.new);
  sl.registerLazySingleton<Vibrator>(() => const HapticVibrator());
  sl.registerLazySingleton<GameFeedbackService>(
    () => GameFeedbackServiceImpl(
      session: sl(),
      settings: sl(),
      sounds: sl(),
      vibrator: sl(),
    ),
  );
}

void _registerReminder(GetIt sl) {
  sl.registerLazySingleton<NotificationScheduler>(
    () => LocalNotificationScheduler(
      plugin: FlutterLocalNotificationsPlugin(),
      texts: _reminderTexts(),
    ),
  );
  sl.registerLazySingleton<ReminderLocalDataSource>(
    () => ReminderLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(local: sl(), notifications: sl()),
  );
  sl.registerLazySingleton<ReminderScheduler>(
    () => ReminderScheduler(repository: sl(), clock: sl()),
  );
  sl.registerLazySingleton<GetReminderSettingsUseCase>(
    () => GetReminderSettingsUseCase(repository: sl()),
  );
  sl.registerLazySingleton<SetReminderEnabledUseCase>(
    () => SetReminderEnabledUseCase(repository: sl(), scheduler: sl()),
  );
  sl.registerLazySingleton<SetReminderTimeUseCase>(
    () => SetReminderTimeUseCase(scheduler: sl()),
  );
  sl.registerLazySingleton<RescheduleRemindersUseCase>(
    () => RescheduleRemindersUseCase(scheduler: sl()),
  );
  sl.registerLazySingleton<RecordFinishedSessionUseCase>(
    () => RecordFinishedSessionUseCase(repository: sl(), scheduler: sl()),
  );
  sl<SessionSavedHooks>().add(
    ReminderSessionHook(
      recordFinishedSession: () => sl<RecordFinishedSessionUseCase>(),
    ),
  );
}

/// The words of the notification, in the phone's language among those
/// of the app; read again at every launch, when the app schedules again.
ReminderNotificationTexts _reminderTexts() {
  final AppLocalizations l10n = lookupAppLocalizations(
    basicLocaleListResolution(
      PlatformDispatcher.instance.locales,
      AppLocalizations.supportedLocales,
    ),
  );
  return ReminderNotificationTexts(
    title: l10n.appTitle,
    body: l10n.reminderNotificationBody,
    channelName: l10n.reminderChannelName,
    channelDescription: l10n.reminderChannelDescription,
  );
}
