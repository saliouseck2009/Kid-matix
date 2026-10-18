import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/setting/data/datasources/language_local_data_source_impl.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_notification_texts.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_notification_texts_reader.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';

import '../../../helpers/in_memory_local_storage.dart';

void main() {
  group('LanguageLocalDataSourceImpl', () {
    test('keeps each language under its code in the preferences', () async {
      // Arrange
      final InMemoryLocalStorage storage = InMemoryLocalStorage();
      final LanguageLocalDataSourceImpl source = LanguageLocalDataSourceImpl(
        storage: storage,
      );
      final List<AppLanguage?> actualLanguages = <AppLanguage?>[
        await source.readLanguage(),
      ];
      final List<String?> actualValues = <String?>[];
      // Act
      for (final AppLanguage language in AppLanguage.values) {
        await source.writeLanguage(language: language);
        actualValues.add(
          await storage.readString(
            key: LanguageLocalDataSourceImpl.languageKey,
          ),
        );
        actualLanguages.add(await source.readLanguage());
      }
      // Assert
      expect(actualValues, <String>['system', 'fr', 'en', 'es']);
      expect(actualLanguages, <AppLanguage?>[null, ...AppLanguage.values]);
    });

    test('ignores a language the app no longer speaks', () async {
      // Arrange
      final InMemoryLocalStorage storage = InMemoryLocalStorage();
      await storage.writeString(
        key: LanguageLocalDataSourceImpl.languageKey,
        value: 'de',
      );
      // Act
      final AppLanguage? actualLanguage = await LanguageLocalDataSourceImpl(
        storage: storage,
      ).readLanguage();
      // Assert
      expect(actualLanguage, isNull);
    });
  });

  group('ReminderNotificationTextsReader', () {
    Future<ReminderNotificationTexts> readTexts({
      AppLanguage? chosen,
      required List<String> phone,
    }) async {
      final InMemoryLocalStorage storage = InMemoryLocalStorage();
      final LanguageLocalDataSourceImpl source = LanguageLocalDataSourceImpl(
        storage: storage,
      );
      if (chosen != null) await source.writeLanguage(language: chosen);
      return ReminderNotificationTextsReader(
        language: source,
        phoneLanguageCodes: () => phone,
      ).read();
    }

    test('speaks the language chosen in the settings', () async {
      // Act
      final ReminderNotificationTexts actualTexts = await readTexts(
        chosen: AppLanguage.english,
        phone: <String>['fr'],
      );
      // Assert
      expect(actualTexts.title, 'Kid Matix');
      expect(actualTexts.body, 'Time for your times tables!');
      expect(actualTexts.channelName, 'Daily reminder');
    });

    test('follows the phone, French when it is not spoken', () async {
      // Act
      final ReminderNotificationTexts actualSpanish = await readTexts(
        phone: <String>['es'],
      );
      final ReminderNotificationTexts actualFrench = await readTexts(
        chosen: AppLanguage.system,
        phone: <String>['de'],
      );
      // Assert
      expect(actualSpanish.channelName, 'Recordatorio diario');
      expect(actualFrench.channelName, 'Rappel quotidien');
    });
  });
}
