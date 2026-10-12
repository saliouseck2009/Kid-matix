import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';
import 'package:kid_matix/features/setting/domain/services/reminder_planner.dart';

import '../helpers/reminder_fixtures.dart';

void main() {
  group('Switching the reminder on', () {
    test('asks for the permission, then schedules from today', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      // Act
      final DataState<ReminderSettings> actual = await bed.setEnabled(
        params: true,
      );
      // Assert
      expect(
        (actual as DataSuccess<ReminderSettings>).data.isEnabled,
        isTrue,
      );
      expect(bed.notifications.permissionRequests, 1);
      expect(bed.notifications.scheduled, hasLength(ReminderPlanner.dayCount));
      expect(bed.notifications.scheduled.first, DateTime(2026, 10, 12, 17));
      final DataState<ReminderSettings> kept = await bed.getSettings();
      expect((kept as DataSuccess<ReminderSettings>).data.isEnabled, isTrue);
    });

    test('stays off with nothing scheduled when refused', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed(
        notifications: FakeNotificationScheduler(isGranted: false),
      );
      // Act
      final DataState<ReminderSettings> actual = await bed.setEnabled(
        params: true,
      );
      // Assert
      expect(
        (actual as DataFailed<ReminderSettings>).exception.code,
        AppErrorCode.permissionDenied,
      );
      expect(bed.notifications.scheduled, isEmpty);
      final DataState<ReminderSettings> kept = await bed.getSettings();
      expect(
        (kept as DataSuccess<ReminderSettings>).data,
        ReminderSettings.initial,
      );
    });

    test('stays off when the plugin cannot schedule', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      await bed.notifications.requestPermission();
      bed.notifications.isBroken = true;
      // Act
      final DataState<ReminderSettings> actual = await bed.setEnabled(
        params: true,
      );
      // Assert
      expect(
        (actual as DataFailed<ReminderSettings>).exception.code,
        AppErrorCode.unknown,
      );
      final DataState<ReminderSettings> kept = await bed.getSettings();
      expect((kept as DataSuccess<ReminderSettings>).data.isEnabled, isFalse);
    });

    test('fails when the preferences cannot be read', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed(
        storage: BrokenLocalStorage(),
      );
      // Act
      final DataState<ReminderSettings> actual = await bed.setEnabled(
        params: true,
      );
      // Assert
      expect(
        (actual as DataFailed<ReminderSettings>).exception.code,
        AppErrorCode.cache,
      );
      expect(bed.notifications.scheduled, isEmpty);
    });
  });

  group('Switching the reminder off', () {
    test('cancels every reminder without asking anything', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      await bed.setEnabled(params: true);
      // Act
      final DataState<ReminderSettings> actual = await bed.setEnabled(
        params: false,
      );
      // Assert
      expect(
        (actual as DataSuccess<ReminderSettings>).data.isEnabled,
        isFalse,
      );
      expect(bed.notifications.scheduled, isEmpty);
      expect(bed.notifications.cancellations, 1);
      expect(bed.notifications.permissionRequests, 1);
    });
  });

  group('Changing the time', () {
    test('schedules every day again at the new time', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      await bed.setEnabled(params: true);
      const ReminderTime inputTime = ReminderTime(hour: 8, minute: 15);
      // Act
      final DataState<ReminderSettings> actual = await bed.setTime(
        params: inputTime,
      );
      // Assert
      expect((actual as DataSuccess<ReminderSettings>).data.time, inputTime);
      expect(bed.notifications.scheduled.first, DateTime(2026, 10, 13, 8, 15));
      expect(
        bed.notifications.scheduled.every(
          (DateTime at) => at.hour == 8 && at.minute == 15,
        ),
        isTrue,
      );
    });

    test('keeps the time but schedules nothing while off', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      const ReminderTime inputTime = ReminderTime(hour: 19, minute: 30);
      // Act
      await bed.setTime(params: inputTime);
      // Assert
      expect(bed.notifications.scheduled, isEmpty);
      expect(bed.notifications.permissionRequests, 0);
      final DataState<ReminderSettings> kept = await bed.getSettings();
      expect((kept as DataSuccess<ReminderSettings>).data.time, inputTime);
    });
  });

  group('A finished session', () {
    test('cancels the reminder of today and keeps the next days', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      await bed.setEnabled(params: true);
      // Act
      final DataState<void> actual = await bed.recordFinishedSession(
        params: DateTime(2026, 10, 12, 11, 20),
      );
      // Assert
      expect(actual, isA<DataSuccess<void>>());
      expect(bed.notifications.scheduled.first, DateTime(2026, 10, 13, 17));
      expect(bed.notifications.scheduled, hasLength(ReminderPlanner.dayCount));
    });

    test('still skips today at the next launch, not tomorrow', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      await bed.setEnabled(params: true);
      await bed.recordFinishedSession(params: DateTime(2026, 10, 12, 11));
      bed.clock.current = DateTime(2026, 10, 12, 15);
      // Act
      await bed.reschedule();
      // Assert
      expect(bed.notifications.scheduled.first, DateTime(2026, 10, 13, 17));
      bed.clock.current = DateTime(2026, 10, 13, 7);
      await bed.reschedule();
      expect(bed.notifications.scheduled.first, DateTime(2026, 10, 13, 17));
    });

    test('schedules nothing while the reminder is off', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      // Act
      await bed.recordFinishedSession(params: DateTime(2026, 10, 12, 11));
      // Assert
      expect(bed.notifications.scheduled, isEmpty);
    });

    test('fails when the day cannot be kept', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed(
        storage: BrokenLocalStorage(),
      );
      // Act
      final DataState<void> actual = await bed.recordFinishedSession(
        params: DateTime(2026, 10, 12, 11),
      );
      // Assert
      expect(
        (actual as DataFailed<void>).exception.code,
        AppErrorCode.cache,
      );
    });
  });

  group('Launching the app', () {
    test('plans the days ahead again from the clock of the phone', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      await bed.setEnabled(params: true);
      bed.clock.current = DateTime(2026, 10, 20, 18);
      // Act
      final DataState<void> actual = await bed.reschedule();
      // Assert
      expect(actual, isA<DataSuccess<void>>());
      expect(bed.notifications.scheduled.first, DateTime(2026, 10, 21, 17));
      expect(bed.notifications.scheduled.last, DateTime(2026, 11, 19, 17));
    });

    test('cancels leftovers when the reminder is off', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      // Act
      await bed.reschedule();
      // Assert
      expect(bed.notifications.cancellations, 1);
      expect(bed.notifications.permissionRequests, 0);
    });

    test('fails when the preferences cannot be read', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed(
        storage: BrokenLocalStorage(),
      );
      // Act
      final DataState<void> actual = await bed.reschedule();
      // Assert
      expect(actual, isA<DataFailed<void>>());
    });
  });
}
