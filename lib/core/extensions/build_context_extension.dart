import 'package:flutter/material.dart';
import 'package:kid_matix/core/theme/app_palette.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Shortcuts to the localized strings and to the design tokens.
extension BuildContextExtension on BuildContext {
  /// Localized strings of the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Design colors that Material's `ColorScheme` has no slot for.
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
