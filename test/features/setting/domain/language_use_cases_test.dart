import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:kid_matix/features/setting/presentation/bloc/language_use_cases.dart';

import '../helpers/language_fixtures.dart';
import '../helpers/reminder_fixtures.dart';

void main() {
  group('Language use cases', () {
    test('the phone language is the default', () async {
      // Arrange
      final LanguageUseCases useCases = LanguageTestBed().useCases;
      // Act
      final DataState<AppLanguage> actualLanguage = await useCases
          .getLanguage();
      // Assert
      expect(
        actualLanguage,
        isA<DataSuccess<AppLanguage>>().having(
          (DataSuccess<AppLanguage> state) => state.data,
          'data',
          AppLanguage.system,
        ),
      );
    });

    test(
      'keeps the language chosen and schedules the reminder again',
      () async {
        // Arrange
        final LanguageTestBed bed = LanguageTestBed();
        await bed.reminder.repository.saveSettings(
          settings: ReminderSettings.initial.copyWith(isEnabled: true),
        );
        // Act
        final DataState<void> actualSave = await bed.useCases.setLanguage(
          params: AppLanguage.spanish,
        );
        final DataState<AppLanguage> actualLanguage = await bed.useCases
            .getLanguage();
        // Assert
        expect(actualSave, isA<DataSuccess<void>>());
        expect(
          (actualLanguage as DataSuccess<AppLanguage>).data,
          AppLanguage.spanish,
        );
        expect(bed.reminder.notifications.scheduled, isNotEmpty);
      },
    );

    test('a reminder that cannot be scheduled does not undo it', () async {
      // Arrange
      final LanguageTestBed bed = LanguageTestBed(
        reminder: ReminderTestBed(
          notifications: FakeNotificationScheduler()..isBroken = true,
        ),
      );
      // Act
      final DataState<void> actualSave = await bed.useCases.setLanguage(
        params: AppLanguage.english,
      );
      // Assert
      expect(actualSave, isA<DataSuccess<void>>());
    });

    test('fails with a storage error when the phone cannot keep it', () async {
      // Arrange
      final LanguageTestBed bed = LanguageTestBed(
        languageStorage: BrokenLocalStorage(),
      );
      // Act
      final DataState<void> actualSave = await bed.useCases.setLanguage(
        params: AppLanguage.english,
      );
      final DataState<AppLanguage> actualRead = await bed.useCases
          .getLanguage();
      // Assert
      expect(
        (actualSave as DataFailed<void>).exception.code,
        AppErrorCode.cache,
      );
      expect(actualRead, isA<DataFailed<AppLanguage>>());
      expect(bed.reminder.notifications.cancellations, 0);
    });
  });
}
