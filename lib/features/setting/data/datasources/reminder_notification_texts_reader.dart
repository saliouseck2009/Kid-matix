import 'dart:ui';

import 'package:kid_matix/features/setting/data/datasources/language_local_data_source.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_notification_texts.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Reads the words of the reminder notification in the language of the
/// interface, each time the reminders are scheduled: a new language
/// reaches the next notifications.
final class ReminderNotificationTextsReader {
  /// Creates the reader; [phoneLanguageCodes] gives the phone's languages,
  /// in its order of preference.
  const ReminderNotificationTextsReader({
    required this._language,
    required this._phoneLanguageCodes,
  });

  final LanguageLocalDataSource _language;
  final List<String> Function() _phoneLanguageCodes;

  /// Returns the texts in the language chosen, or the phone's.
  Future<ReminderNotificationTexts> read() async {
    final AppLanguage chosen =
        await _language.readLanguage() ?? AppLanguage.system;
    final AppLanguage shown = chosen.resolve(
      phoneLanguageCodes: _phoneLanguageCodes(),
    );
    final AppLocalizations l10n = lookupAppLocalizations(
      Locale(shown.languageCode!),
    );
    return ReminderNotificationTexts(
      title: l10n.appTitle,
      body: l10n.reminderNotificationBody,
      channelName: l10n.reminderChannelName,
      channelDescription: l10n.reminderChannelDescription,
    );
  }
}
