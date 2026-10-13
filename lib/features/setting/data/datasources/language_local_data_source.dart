import 'package:kid_matix/features/setting/domain/entities/app_language.dart';

/// The language of the interface kept in the device preferences, shared
/// by every player of the phone.
///
/// Methods throw the storage errors as they come; the repository turns
/// them into typed failures.
abstract interface class LanguageLocalDataSource {
  /// The language chosen, or `null` when never chosen or unreadable.
  Future<AppLanguage?> readLanguage();

  /// Keeps [language].
  Future<void> writeLanguage({required AppLanguage language});
}
