import 'dart:ui';

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
import 'package:kid_matix/features/setting/data/datasources/language_local_data_source.dart';
import 'package:kid_matix/features/setting/data/datasources/language_local_data_source_impl.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_notification_texts_reader.dart';
import 'package:kid_matix/features/setting/data/repositories/language_repository_impl.dart';
import 'package:kid_matix/features/setting/domain/repositories/language_repository.dart';
import 'package:kid_matix/features/setting/domain/usecases/get_app_language_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/set_app_language_use_case.dart';
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

/// Registers the sounds and vibrations of the game, the language of the
/// interface and the daily reminder in [sl].
void registerSettingFeature(GetIt sl) {
  _registerGameFeedback(sl);
  _registerLanguage(sl);
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

void _registerLanguage(GetIt sl) {
  sl.registerLazySingleton<LanguageLocalDataSource>(
    () => LanguageLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<LanguageRepository>(
    () => LanguageRepositoryImpl(local: sl()),
  );
  sl.registerLazySingleton<GetAppLanguageUseCase>(
    () => GetAppLanguageUseCase(repository: sl()),
  );
  sl.registerLazySingleton<SetAppLanguageUseCase>(
    () => SetAppLanguageUseCase(repository: sl(), scheduler: sl()),
  );
}

void _registerReminder(GetIt sl) {
  sl.registerLazySingleton<NotificationScheduler>(
    () => LocalNotificationScheduler(
      plugin: FlutterLocalNotificationsPlugin(),
      readTexts: ReminderNotificationTextsReader(
        language: sl(),
        phoneLanguageCodes: _readPhoneLanguageCodes,
      ).read,
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

/// The phone's languages, in its order of preference.
List<String> _readPhoneLanguageCodes() {
  return <String>[
    for (final Locale locale in PlatformDispatcher.instance.locales)
      locale.languageCode,
  ];
}
