import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';
import 'package:kid_matix/features/setting/presentation/bloc/language_cubit.dart';
import 'package:kid_matix/features/setting/presentation/bloc/language_state.dart';
import 'package:kid_matix/features/setting/presentation/bloc/language_use_cases.dart';
import 'package:kid_matix/features/setting/presentation/widgets/language_settings_rows.dart';

/// Builds the language of the interface: the scope above the app and the
/// rows of the settings screen.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class LanguagePages {
  /// Creates the factory.
  const LanguagePages({required this._useCases});

  final LanguageUseCases _useCases;

  /// Reads the language kept, before the first frame, so the app opens in
  /// it; the phone's language when it cannot be read.
  Future<AppLanguage> readLanguage() async {
    return switch (await _useCases.getLanguage()) {
      DataSuccess<AppLanguage>(:final data) => data,
      DataFailed<AppLanguage>() => AppLanguage.system,
    };
  }

  /// Gives the language to the whole app, starting on [initial]:
  /// [builder] builds the app for the locale chosen, `null` to follow
  /// the phone (see [resolveLocale]).
  Widget buildAppScope({
    required AppLanguage initial,
    required Widget Function(Locale? locale) builder,
  }) {
    return BlocProvider<LanguageCubit>(
      create: (_) => LanguageCubit(useCases: _useCases, initial: initial),
      child: BlocBuilder<LanguageCubit, LanguageState>(
        buildWhen: (LanguageState previous, LanguageState current) =>
            previous.language != current.language,
        builder: (BuildContext context, LanguageState state) {
          return builder(switch (state.language.languageCode) {
            final String code => Locale(code),
            null => null,
          });
        },
      ),
    );
  }

  /// The rows of the « Langue » section of the settings screen.
  Widget buildSettingsRows() => const LanguageSettingsRows();

  /// The locale the app shows among [supported] for the [preferred]
  /// locales (the chosen one, or the phone's in order): the first whose
  /// language the app speaks, French otherwise.
  static Locale resolveLocale(
    List<Locale>? preferred,
    Iterable<Locale> supported,
  ) {
    final AppLanguage language = AppLanguage.system.resolve(
      phoneLanguageCodes: <String>[
        for (final Locale locale in preferred ?? const <Locale>[])
          locale.languageCode,
      ],
    );
    return supported.firstWhere(
      (Locale locale) => locale.languageCode == language.languageCode,
    );
  }
}
