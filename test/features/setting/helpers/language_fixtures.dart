import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/setting/data/datasources/language_local_data_source_impl.dart';
import 'package:kid_matix/features/setting/data/repositories/language_repository_impl.dart';
import 'package:kid_matix/features/setting/domain/repositories/language_repository.dart';
import 'package:kid_matix/features/setting/domain/usecases/get_app_language_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/set_app_language_use_case.dart';
import 'package:kid_matix/features/setting/presentation/bloc/language_use_cases.dart';
import 'package:kid_matix/features/setting/presentation/language_pages.dart';

import 'reminder_fixtures.dart';

/// The language of the interface over fakes: the real repository on the
/// storage of a [ReminderTestBed], whose reminder follows the language.
final class LanguageTestBed {
  /// Builds the bed; [languageStorage] replaces the storage of the
  /// language only, such as a broken one.
  LanguageTestBed({LocalStorage? languageStorage, ReminderTestBed? reminder})
    : reminder = reminder ?? ReminderTestBed() {
    repository = LanguageRepositoryImpl(
      local: LanguageLocalDataSourceImpl(
        storage: languageStorage ?? this.reminder.storage,
      ),
    );
  }

  /// The reminder of the phone.
  final ReminderTestBed reminder;

  /// Repository of the language.
  late final LanguageRepository repository;

  /// The use cases of the language.
  LanguageUseCases get useCases => LanguageUseCases(
    getLanguage: GetAppLanguageUseCase(repository: repository),
    setLanguage: SetAppLanguageUseCase(
      repository: repository,
      scheduler: reminder.scheduler,
    ),
  );

  /// The pages of the language.
  LanguagePages get pages => LanguagePages(useCases: useCases);
}
