import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';

void main() {
  group('ReminderSettings', () {
    test('is off at 17:00 by default', () {
      // Act
      const ReminderSettings actual = ReminderSettings.initial;
      // Assert
      expect(actual.isEnabled, isFalse);
      expect(actual.time, const ReminderTime(hour: 17, minute: 0));
    });

    test('compares by value and copies with changes', () {
      // Arrange
      const ReminderSettings inputSettings = ReminderSettings.initial;
      const ReminderSettings expected = ReminderSettings(
        isEnabled: true,
        time: ReminderTime(hour: 9, minute: 0),
      );
      // Act
      final ReminderSettings actual = inputSettings.copyWith(
        isEnabled: true,
        time: const ReminderTime(hour: 9, minute: 0),
      );
      // Assert
      expect(actual, expected);
      expect(actual.hashCode, expected.hashCode);
      expect(actual, isNot(inputSettings));
      expect(inputSettings.copyWith(), inputSettings);
      expect(actual.toString(), contains('true'));
    });
  });
}
