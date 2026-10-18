import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';

void main() {
  group('AppLanguage', () {
    test('finds a language of the app by its code', () {
      // Act
      final List<AppLanguage?> actualLanguages = <AppLanguage?>[
        for (final String code in <String>['fr', 'en', 'es', 'de'])
          AppLanguage.fromCode(code),
      ];
      // Assert
      expect(actualLanguages, <AppLanguage?>[
        AppLanguage.french,
        AppLanguage.english,
        AppLanguage.spanish,
        null,
      ]);
    });

    test('the phone language is the first the app speaks', () {
      // Act
      final AppLanguage actualLanguage = AppLanguage.system.resolve(
        phoneLanguageCodes: <String>['de', 'es', 'en'],
      );
      // Assert
      expect(actualLanguage, AppLanguage.spanish);
    });

    test('falls back to French when the phone speaks none of them', () {
      // Act
      final AppLanguage actualLanguage = AppLanguage.system.resolve(
        phoneLanguageCodes: <String>['de', 'it'],
      );
      // Assert
      expect(actualLanguage, AppLanguage.french);
    });

    test('a chosen language wins over the phone', () {
      // Act
      final AppLanguage actualLanguage = AppLanguage.english.resolve(
        phoneLanguageCodes: <String>['es'],
      );
      // Assert
      expect(actualLanguage, AppLanguage.english);
    });
  });
}
