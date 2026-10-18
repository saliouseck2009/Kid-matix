import 'package:kid_matix/features/setting/domain/usecases/get_app_language_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/set_app_language_use_case.dart';

/// The use cases of the language of the interface.
final class LanguageUseCases {
  /// Groups the use cases.
  const LanguageUseCases({
    required this.getLanguage,
    required this.setLanguage,
  });

  /// Reads the language chosen.
  final GetAppLanguageUseCase getLanguage;

  /// Changes it.
  final SetAppLanguageUseCase setLanguage;
}
