import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kid_matix/core/services/notification_scheduler.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_notification_texts.dart';
import 'package:timezone/timezone.dart' as tz;

/// [NotificationScheduler] over `flutter_local_notifications`.
///
/// Each reminder is one notification at an instant computed from the
/// phone's local time when it is scheduled; the app schedules again at
/// every launch, so a change of time zone is caught then. Android uses an
/// inexact alarm (no exact alarm permission): the reminder may come a few
/// minutes late. Tapping it opens the app.
final class LocalNotificationScheduler implements NotificationScheduler {
  /// Creates the scheduler over [plugin], with the words of [texts].
  LocalNotificationScheduler({required this._plugin, required this._texts});

  /// Android drawable of the small icon (`res/drawable/ic_notification`).
  static const String androidIcon = 'ic_notification';

  /// Android channel of the reminder.
  static const String channelId = 'daily_reminder';

  /// Id of the first reminder; the next days follow it.
  static const int firstReminderId = 1800;

  final FlutterLocalNotificationsPlugin _plugin;
  final ReminderNotificationTexts _texts;
  Future<void>? _initialization;

  @override
  Future<bool> requestPermission() async {
    await _initialize();
    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final IOSFlutterLocalNotificationsPlugin? ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final bool? isGranted =
        await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, sound: true);
    return isGranted ?? false;
  }

  @override
  Future<void> scheduleReminders({required List<DateTime> times}) async {
    await cancelReminders();
    for (int index = 0; index < times.length; index++) {
      await _plugin.zonedSchedule(
        id: firstReminderId + index,
        title: _texts.title,
        body: _texts.body,
        scheduledDate: tz.TZDateTime.from(times[index], tz.UTC),
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelReminders() async {
    await _initialize();
    await _plugin.cancelAll();
  }

  /// Sets the plugin up once, without asking for any permission: iOS
  /// would otherwise ask at the first launch.
  Future<void> _initialize() {
    return _initialization ??= _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(androidIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
    );
  }

  NotificationDetails _details() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _texts.channelName,
        channelDescription: _texts.channelDescription,
        icon: androidIcon,
        color: AppColors.violet,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }
}
