import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';

/// The language of the interface, kept on the phone for every player.
abstract interface class LanguageRepository {
  /// Returns the language chosen, [AppLanguage.system] when never chosen.
  Future<DataState<AppLanguage>> getLanguage();

  /// Keeps [language].
  Future<DataState<void>> saveLanguage({required AppLanguage language});
}
