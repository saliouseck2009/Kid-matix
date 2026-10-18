import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Pumps [child] inside a themed app localized in [locale], French by
/// default (the test device speaks English).
Future<void> pumpLocalized(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('fr'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
  await tester.pump();
}
