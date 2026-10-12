import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/setting/data/datasources/local_notification_scheduler.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_notification_texts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/timezone.dart' as tz;

final class _MockPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

final class _MockAndroidPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

final class _MockIosPlugin extends Mock
    implements IOSFlutterLocalNotificationsPlugin {}

const ReminderNotificationTexts _texts = ReminderNotificationTexts(
  title: 'Kid Matix',
  body: "C'est l'heure de tes tables !",
  channelName: 'Rappel quotidien',
  channelDescription: 'Te rappelle de jouer.',
);

void main() {
  late _MockPlugin mockPlugin;
  late LocalNotificationScheduler scheduler;

  setUpAll(() {
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
    registerFallbackValue(tz.TZDateTime.utc(2026));
  });

  setUp(() {
    mockPlugin = _MockPlugin();
    scheduler = LocalNotificationScheduler(plugin: mockPlugin, texts: _texts);
    when(
      () => mockPlugin.initialize(settings: any(named: 'settings')),
    ).thenAnswer((_) async => true);
    when(mockPlugin.cancelAll).thenAnswer((_) async {});
    when(
      () => mockPlugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      ),
    ).thenAnswer((_) async {});
  });

  group('LocalNotificationScheduler', () {
    test('initializes once, asking iOS for nothing', () async {
      // Act
      await scheduler.cancelReminders();
      await scheduler.cancelReminders();
      // Assert
      final InitializationSettings actual =
          verify(
                () => mockPlugin.initialize(
                  settings: captureAny(named: 'settings'),
                ),
              ).captured.single
              as InitializationSettings;
      expect(actual.iOS?.requestAlertPermission, isFalse);
      expect(actual.iOS?.requestSoundPermission, isFalse);
      expect(actual.iOS?.requestBadgePermission, isFalse);
      expect(
        actual.android?.defaultIcon,
        LocalNotificationScheduler.androidIcon,
      );
      verify(mockPlugin.cancelAll).called(2);
    });

    test('replaces the reminders by one inexact notification a day', () async {
      // Arrange
      final List<DateTime> inputTimes = <DateTime>[
        DateTime(2026, 10, 12, 17),
        DateTime(2026, 10, 13, 17),
      ];
      // Act
      await scheduler.scheduleReminders(times: inputTimes);
      // Assert
      verify(mockPlugin.cancelAll).called(1);
      final List<dynamic> actual = verify(
        () => mockPlugin.zonedSchedule(
          id: captureAny(named: 'id'),
          title: 'Kid Matix',
          body: "C'est l'heure de tes tables !",
          scheduledDate: captureAny(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        ),
      ).captured;
      expect(actual, <Object>[
        LocalNotificationScheduler.firstReminderId,
        tz.TZDateTime.from(inputTimes[0], tz.UTC),
        LocalNotificationScheduler.firstReminderId + 1,
        tz.TZDateTime.from(inputTimes[1], tz.UTC),
      ]);
      expect(
        (actual[1] as tz.TZDateTime).millisecondsSinceEpoch,
        inputTimes[0].millisecondsSinceEpoch,
      );
    });

    test('asks Android for the notifications', () async {
      // Arrange
      final _MockAndroidPlugin mockAndroid = _MockAndroidPlugin();
      when(
        () => mockPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(mockAndroid);
      when(
        () => mockPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(null);
      when(
        mockAndroid.requestNotificationsPermission,
      ).thenAnswer((_) async => false);
      // Act
      final bool actual = await scheduler.requestPermission();
      // Assert
      expect(actual, isFalse);
    });

    test('asks iOS for alerts and sounds', () async {
      // Arrange
      final _MockIosPlugin mockIos = _MockIosPlugin();
      when(
        () => mockPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(null);
      when(
        () => mockPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(mockIos);
      when(
        () => mockIos.requestPermissions(alert: true, sound: true),
      ).thenAnswer((_) async => true);
      // Act
      final bool actual = await scheduler.requestPermission();
      // Assert
      expect(actual, isTrue);
    });

    test('counts no answer as a refusal', () async {
      // Arrange
      when(
        () => mockPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(null);
      when(
        () => mockPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(null);
      // Act
      final bool actual = await scheduler.requestPermission();
      // Assert
      expect(actual, isFalse);
    });
  });
}
