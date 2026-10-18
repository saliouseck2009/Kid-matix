/// Language of the interface, chosen for the whole phone in the settings.
///
/// [system] follows the phone; the others force one language of the app.
enum AppLanguage {
  /// The phone's language when the app speaks it, French otherwise.
  system(languageCode: null),

  /// Français.
  french(languageCode: 'fr'),

  /// English.
  english(languageCode: 'en'),

  /// Español.
  spanish(languageCode: 'es');

  const AppLanguage({required this.languageCode});

  /// Language shown when the phone speaks none of the app's languages.
  static const AppLanguage fallback = french;

  /// ISO 639-1 code of the language, or `null` for [system].
  final String? languageCode;

  /// Returns the language whose code is [languageCode], or `null` when
  /// the app does not speak it.
  static AppLanguage? fromCode(String languageCode) {
    for (final AppLanguage language in values) {
      if (language.languageCode == languageCode) return language;
    }
    return null;
  }

  /// The language the interface shows: this one, or for [system] the
  /// first of [phoneLanguageCodes] (in the phone's order of preference)
  /// that the app speaks, [fallback] when none.
  AppLanguage resolve({required List<String> phoneLanguageCodes}) {
    if (this != system) return this;
    for (final String code in phoneLanguageCodes) {
      if (fromCode(code) case final AppLanguage language) return language;
    }
    return fallback;
  }
}
