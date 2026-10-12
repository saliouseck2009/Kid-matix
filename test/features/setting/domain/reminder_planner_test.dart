import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';
import 'package:kid_matix/features/setting/domain/services/reminder_planner.dart';

void main() {
  const ReminderPlanner planner = ReminderPlanner();
  const ReminderTime fivePm = ReminderTime.initial;

  group('ReminderPlanner', () {
    test('plans one reminder a day from today when the time is ahead', () {
      // Arrange
      final DateTime inputNow = DateTime(2026, 10, 12, 10);
      // Act
      final List<DateTime> actual = planner.planReminders(
        now: inputNow,
        time: fivePm,
      );
      // Assert
      expect(actual, hasLength(ReminderPlanner.dayCount));
      expect(actual.first, DateTime(2026, 10, 12, 17));
      expect(actual[1], DateTime(2026, 10, 13, 17));
      expect(actual.last, DateTime(2026, 11, 10, 17));
    });

    test('starts tomorrow once the time of today has passed', () {
      // Arrange
      final DateTime inputNow = DateTime(2026, 10, 12, 17, 0, 1);
      // Act
      final List<DateTime> actual = planner.planReminders(
        now: inputNow,
        time: fivePm,
      );
      // Assert
      expect(actual, hasLength(ReminderPlanner.dayCount));
      expect(actual.first, DateTime(2026, 10, 13, 17));
    });

    test('leaves today out when a session was finished today', () {
      // Arrange
      final DateTime inputNow = DateTime(2026, 10, 12, 9);
      // Act
      final List<DateTime> actual = planner.planReminders(
        now: inputNow,
        time: fivePm,
        lastSessionDay: DateTime(2026, 10, 12),
      );
      // Assert
      expect(actual.first, DateTime(2026, 10, 13, 17));
      expect(actual, hasLength(ReminderPlanner.dayCount));
    });

    test('keeps today when the last session was yesterday', () {
      // Arrange
      final DateTime inputNow = DateTime(2026, 10, 12, 9);
      // Act
      final List<DateTime> actual = planner.planReminders(
        now: inputNow,
        time: fivePm,
        lastSessionDay: DateTime(2026, 10, 11),
      );
      // Assert
      expect(actual.first, DateTime(2026, 10, 12, 17));
    });

    test('crosses the end of the year and keeps the local hour', () {
      // Arrange
      final DateTime inputNow = DateTime(2026, 12, 31, 20);
      const ReminderTime inputTime = ReminderTime(hour: 8, minute: 30);
      // Act
      final List<DateTime> actual = planner.planReminders(
        now: inputNow,
        time: inputTime,
      );
      // Assert
      expect(actual.first, DateTime(2027, 1, 1, 8, 30));
      expect(
        actual.every((DateTime at) => at.hour == 8 && at.minute == 30),
        isTrue,
      );
    });

    test('gives every day once, without gaps', () {
      // Arrange
      final DateTime inputNow = DateTime(2026, 3, 20, 6);
      // Act
      final List<DateTime> actual = planner.planReminders(
        now: inputNow,
        time: fivePm,
      );
      // Assert
      for (int index = 1; index < actual.length; index++) {
        final DateTime previous = actual[index - 1];
        expect(
          actual[index],
          DateTime(previous.year, previous.month, previous.day + 1, 17),
        );
      }
    });
  });

  group('ReminderTime', () {
    test('compares by value and copies with changes', () {
      // Arrange
      const ReminderTime inputTime = ReminderTime(hour: 7, minute: 5);
      // Act
      final ReminderTime actual = inputTime.copyWith(minute: 45);
      // Assert
      expect(actual, const ReminderTime(hour: 7, minute: 45));
      expect(actual.hashCode, const ReminderTime(hour: 7, minute: 45).hashCode);
      expect(inputTime.copyWith(), inputTime);
      expect(actual.toString(), contains('7:45'));
    });

    test('falls on the day given, local time', () {
      // Act
      final DateTime actual = const ReminderTime(
        hour: 18,
        minute: 15,
      ).onDay(DateTime(2026, 2, 3, 23, 59));
      // Assert
      expect(actual, DateTime(2026, 2, 3, 18, 15));
    });
  });
}
