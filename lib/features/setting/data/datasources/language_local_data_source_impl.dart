import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/setting/data/datasources/language_local_data_source.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';

/// [LanguageLocalDataSource] over the device preferences.
final class LanguageLocalDataSourceImpl implements LanguageLocalDataSource {
  /// Creates the data source over [storage].
  const LanguageLocalDataSourceImpl({required this._storage});

  /// Preference key of the language: its ISO 639-1 code, or [systemValue].
  static const String languageKey = 'app_language';

  /// Stored value of [AppLanguage.system].
  static const String systemValue = 'system';

  final LocalStorage _storage;

  @override
  Future<AppLanguage?> readLanguage() async {
    final String? value = await _storage.readString(key: languageKey);
    return switch (value) {
      null => null,
      systemValue => AppLanguage.system,
      final String code => AppLanguage.fromCode(code),
    };
  }

  @override
  Future<void> writeLanguage({required AppLanguage language}) {
    return _storage.writeString(
      key: languageKey,
      value: language.languageCode ?? systemValue,
    );
  }
}
