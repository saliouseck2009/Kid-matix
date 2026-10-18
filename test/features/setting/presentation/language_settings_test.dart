import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:kid_matix/features/setting/data/datasources/language_local_data_source_impl.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';
import 'package:kid_matix/features/setting/presentation/language_pages.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

import '../../profile/helpers/profile_fixtures.dart';
import '../helpers/language_fixtures.dart';
import '../helpers/reminder_fixtures.dart';

void main() {
  Future<void> pumpSettings(
    WidgetTester tester,
    LanguageTestBed bed, {
    AppLanguage initial = AppLanguage.system,
  }) async {
    tester.view.physicalSize = const Size(1080, 4000);
    addTearDown(tester.view.resetPhysicalSize);
    final ProfilePages profilePages = buildProfilePages();
    final LanguagePages pages = bed.pages;
    await tester.pumpWidget(
      pages.buildAppScope(
        initial: initial,
        builder: (Locale? locale) => MaterialApp(
          theme: AppTheme.light,
          locale: locale,
          localeListResolutionCallback: LanguagePages.resolveLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: profilePages.buildSettingsPage(
            profileId: 'profile-1',
            onBack: () {},
            languageRows: <Widget>[pages.buildSettingsRows()],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void setPhoneLanguages(WidgetTester tester, List<Locale> locales) {
    tester.platformDispatcher.localesTestValue = locales;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }

  group('« Langue » section of the settings', () {
    testWidgets('follows the phone by default, French when not spoken', (
      WidgetTester tester,
    ) async {
      // Arrange
      setPhoneLanguages(tester, const <Locale>[Locale('de', 'DE')]);
      // Act
      await pumpSettings(tester, LanguageTestBed());
      // Assert
      expect(find.text('Réglages'), findsOneWidget);
      expect(find.text('Langue'), findsOneWidget);
      for (final String name in <String>[
        'Langue du téléphone',
        'Français',
        'English',
        'Español',
      ]) {
        expect(find.text(name), findsOneWidget);
      }
    });

    testWidgets('shows the phone language when the app speaks it', (
      WidgetTester tester,
    ) async {
      // Arrange
      setPhoneLanguages(tester, const <Locale>[
        Locale('de'),
        Locale('es', 'MX'),
      ]);
      // Act
      await pumpSettings(tester, LanguageTestBed());
      // Assert
      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.text('Idioma del teléfono'), findsOneWidget);
    });

    testWidgets('switches the app live and keeps the choice', (
      WidgetTester tester,
    ) async {
      // Arrange
      setPhoneLanguages(tester, const <Locale>[Locale('fr', 'FR')]);
      final LanguageTestBed bed = LanguageTestBed();
      await pumpSettings(tester, bed);
      // Act
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Phone language'), findsOneWidget);
      expect(
        await bed.reminder.storage.readString(
          key: LanguageLocalDataSourceImpl.languageKey,
        ),
        'en',
      );
    });

    testWidgets('a choice that cannot be kept goes back, with a message', (
      WidgetTester tester,
    ) async {
      // Arrange
      setPhoneLanguages(tester, const <Locale>[Locale('fr', 'FR')]);
      final LanguageTestBed bed = LanguageTestBed(
        languageStorage: BrokenLocalStorage(),
      );
      await pumpSettings(tester, bed, initial: AppLanguage.french);
      // Act
      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Réglages'), findsOneWidget);
      expect(
        find.text("Oups, la langue n'a pas pu être enregistrée."),
        findsOneWidget,
      );
    });
  });
}
