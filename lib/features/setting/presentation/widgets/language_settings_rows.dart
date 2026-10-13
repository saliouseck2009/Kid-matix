import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';
import 'package:kid_matix/features/setting/presentation/bloc/language_cubit.dart';
import 'package:kid_matix/features/setting/presentation/bloc/language_state.dart';

/// The rows of the « Langue » section of the settings screen: the phone's
/// language, then each language of the app written in itself, for the
/// whole phone. The app changes language as soon as one is tapped.
class LanguageSettingsRows extends StatelessWidget {
  /// Creates the rows; the language comes from the Cubit above the app.
  const LanguageSettingsRows({super.key});

  static const double _dividerThickness = 2;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LanguageCubit, LanguageState>(
      listenWhen: (LanguageState previous, LanguageState current) =>
          current.errorCode != null,
      listener: (BuildContext context, LanguageState state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(context.l10n.settingsLanguageError)),
          );
      },
      builder: (BuildContext context, LanguageState state) {
        return RadioGroup<AppLanguage>(
          groupValue: state.language,
          onChanged: (AppLanguage? language) {
            if (language == null || state.isSaving) return;
            context.read<LanguageCubit>().select(language);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final AppLanguage language
                  in AppLanguage.values) ...<Widget>[
                if (language != AppLanguage.values.first)
                  Divider(
                    height: _dividerThickness,
                    thickness: _dividerThickness,
                    color: context.palette.tint,
                  ),
                _LanguageRow(language: language),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final String name = switch (language) {
      AppLanguage.system => context.l10n.settingsLanguageSystem,
      AppLanguage.french => context.l10n.languageNameFrench,
      AppLanguage.english => context.l10n.languageNameEnglish,
      AppLanguage.spanish => context.l10n.languageNameSpanish,
    };
    return RadioListTile<AppLanguage>(
      key: ValueKey<AppLanguage>(language),
      value: language,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
      title: Text(
        name,
        locale: switch (language.languageCode) {
          final String code => Locale(code),
          null => null,
        },
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
