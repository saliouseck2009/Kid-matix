import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';
import 'package:kid_matix/features/setting/presentation/bloc/language_state.dart';
import 'package:kid_matix/features/setting/presentation/bloc/language_use_cases.dart';

/// The language of the interface, for the whole phone: the app follows
/// it live, without restarting.
final class LanguageCubit extends Cubit<LanguageState> {
  /// Creates the Cubit, starting on [initial], read before the first
  /// frame so the app opens in the right language.
  LanguageCubit({required this._useCases, required AppLanguage initial})
    : super(LanguageState(language: initial));

  final LanguageUseCases _useCases;

  /// Shows [language] at once and keeps it; when it cannot be kept, the
  /// previous language comes back.
  Future<void> select(AppLanguage language) async {
    final AppLanguage previous = state.language;
    if (language == previous || state.isSaving) return;
    emit(LanguageState(language: language, isSaving: true));
    final DataState<void> saved = await _useCases.setLanguage(
      params: language,
    );
    if (isClosed) return;
    emit(switch (saved) {
      DataSuccess<void>() => LanguageState(language: language),
      DataFailed<void>(:final exception) => LanguageState(
        language: previous,
        errorCode: exception.code,
      ),
    });
  }
}
